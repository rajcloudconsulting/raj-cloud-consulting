const menuButton = document.querySelector('.menu-toggle');
const navigation = document.querySelector('.nav-links');

menuButton?.addEventListener('click', () => {
  const open = navigation.classList.toggle('open');
  menuButton.setAttribute('aria-expanded', String(open));
});

document.querySelectorAll('.nav-links a').forEach(link => {
  link.addEventListener('click', () => {
    navigation.classList.remove('open');
    menuButton?.setAttribute('aria-expanded', 'false');
  });
});

document.getElementById('year').textContent = new Date().getFullYear();

const glow = document.querySelector('.cursor-glow');
window.addEventListener('pointermove', event => {
  if (!glow) return;
  glow.style.left = `${event.clientX}px`;
  glow.style.top = `${event.clientY}px`;
});

const revealObserver = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll('.reveal').forEach(element => revealObserver.observe(element));

const countObserver = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (!entry.isIntersecting) return;
    const element = entry.target;
    const target = Number(element.dataset.count || 0);
    const suffix = target === 100 ? '%' : '+';
    const duration = 1200;
    const start = performance.now();

    const animate = now => {
      const progress = Math.min((now - start) / duration, 1);
      element.textContent = `${Math.round(target * progress)}${suffix}`;
      if (progress < 1) requestAnimationFrame(animate);
    };
    requestAnimationFrame(animate);
    countObserver.unobserve(element);
  });
}, { threshold: 0.6 });

document.querySelectorAll('[data-count]').forEach(element => countObserver.observe(element));

document.querySelectorAll('.tech-node').forEach(node => {
  const activate = () => {
    document.querySelectorAll('.tech-node').forEach(item => item.classList.remove('active'));
    node.classList.add('active');

    const detail = document.getElementById('visual-detail');
    detail.innerHTML = `
      <span class="detail-label">${node.querySelector('strong').textContent}</span>
      <strong>${node.querySelector('small').textContent}</strong>
      <p>${node.dataset.detail}</p>
    `;
  };

  node.addEventListener('mouseenter', activate);
  node.addEventListener('focus', activate);
  node.addEventListener('click', activate);
});

document.querySelectorAll('.tilt-card').forEach(card => {
  card.addEventListener('pointermove', event => {
    const rect = card.getBoundingClientRect();
    const x = (event.clientX - rect.left) / rect.width - 0.5;
    const y = (event.clientY - rect.top) / rect.height - 0.5;
    card.style.transform = `perspective(800px) rotateY(${x * 7}deg) rotateX(${y * -7}deg) translateY(-4px)`;
  });

  card.addEventListener('pointerleave', () => {
    card.style.transform = '';
  });
});

const architectureData = {
  intune: {
    title: 'Microsoft Intune',
    description: 'Endpoint configuration, application delivery, compliance, Windows remediation and modern management.',
    tags: ['Detection', 'Remediation', 'Windows 11']
  },
  avd: {
    title: 'Azure Virtual Desktop',
    description: 'Golden image readiness, FSLogix, Teams optimisation, session policy and cloud-desktop troubleshooting.',
    tags: ['AVD', 'FSLogix', 'Teams']
  },
  azure: {
    title: 'Microsoft Azure',
    description: 'Governance, identity, networking, private endpoints, compute and secure resource operations.',
    tags: ['RBAC', 'Networking', 'Governance']
  },
  defender: {
    title: 'Microsoft Defender',
    description: 'Endpoint health, attack-surface reduction, indicator workflows and security posture improvement.',
    tags: ['Defender XDR', 'IOC', 'Hardening']
  },
  m365: {
    title: 'Microsoft 365',
    description: 'Exchange Online, Teams, SharePoint and productivity-platform administration.',
    tags: ['Exchange', 'Teams', 'SharePoint']
  },
  automation: {
    title: 'PowerShell Automation',
    description: 'Reusable administration, reporting, detection, remediation and controlled operational change.',
    tags: ['PowerShell', 'Automation', 'APIs']
  }
};

document.querySelectorAll('.arch-node').forEach(node => {
  node.addEventListener('click', () => {
    document.querySelectorAll('.arch-node').forEach(item => item.classList.remove('selected'));
    node.classList.add('selected');

    const data = architectureData[node.dataset.arch];
    document.getElementById('arch-title').textContent = data.title;
    document.getElementById('arch-description').textContent = data.description;
    document.getElementById('arch-tags').innerHTML = data.tags.map(tag => `<span>${tag}</span>`).join('');
  });
});

const terminalSteps = [
  { command: 'Connect-AzAccount', lines: ['Connected to Microsoft Azure context.', 'Subscription context validated.'], className: 'output-success' },
  { command: 'Test-CloudSecurityPosture', lines: ['Checking Defender health...', 'Checking Intune compliance...', 'Checking private endpoint DNS...'], className: 'output-muted' },
  { command: 'Invoke-CloudAutomation -Mode Safe', lines: ['Generating operational report...', 'Applying documented remediation...', 'Validation completed successfully.'], className: 'output-success' },
  { command: 'Get-RajCloudPortfolio', lines: ['23 sanitised scripts available.', 'Azure | Intune | Defender | AVD | M365 | PowerShell'], className: 'output-warning' }
];

const terminal = document.getElementById('terminal-output');
const commandElement = terminal?.querySelector('.typed-command');

async function typeText(element, text, speed = 34) {
  element.textContent = '';
  for (const character of text) {
    element.textContent += character;
    await new Promise(resolve => setTimeout(resolve, speed));
  }
}

async function runTerminal() {
  if (!terminal || !commandElement) return;

  for (const step of terminalSteps) {
    await typeText(commandElement, step.command);
    await new Promise(resolve => setTimeout(resolve, 350));

    step.lines.forEach(line => {
      const output = document.createElement('div');
      output.className = step.className;
      output.textContent = line;
      terminal.appendChild(output);
    });

    await new Promise(resolve => setTimeout(resolve, 650));

    const next = document.createElement('div');
    next.innerHTML = '<span class="prompt">PS C:\\Cloud&gt;</span> <span class="typed-command"></span><span class="terminal-cursor">▋</span>';
    terminal.appendChild(next);
    commandElement.classList.remove('typed-command');
    window.currentCommandElement = next.querySelector('.typed-command');
    commandElement.replaceWith(window.currentCommandElement);
  }
}

const terminalObserver = new IntersectionObserver(entries => {
  if (entries[0].isIntersecting) {
    runTerminal();
    terminalObserver.disconnect();
  }
}, { threshold: 0.45 });

if (terminal) terminalObserver.observe(terminal);

document.querySelectorAll('.filter-button').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.filter-button').forEach(item => item.classList.remove('active'));
    button.classList.add('active');

    const filter = button.dataset.filter;
    document.querySelectorAll('.script-card').forEach(card => {
      const category = card.dataset.category;
      card.hidden = filter !== 'all' && category !== filter && category !== 'all';
    });
  });
});

const portalToggle = document.querySelector('.portal-toggle');
const portalSection = document.getElementById('cloud-console');
const portalClose = document.querySelector('.portal-close');

portalToggle?.addEventListener('click', () => {
  portalSection?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  portalToggle.setAttribute('aria-expanded', 'true');
});

portalClose?.addEventListener('click', () => {
  document.getElementById('top')?.scrollIntoView({ behavior: 'smooth' });
  portalToggle?.setAttribute('aria-expanded', 'false');
});

document.querySelectorAll('.portal-nav').forEach(button => {
  button.addEventListener('click', () => {
    const target = button.dataset.panel;
    document.querySelectorAll('.portal-nav').forEach(item => item.classList.remove('active'));
    document.querySelectorAll('.portal-panel').forEach(panel => panel.classList.remove('active'));
    button.classList.add('active');
    document.querySelector(`[data-portal-panel="${target}"]`)?.classList.add('active');
  });
});
