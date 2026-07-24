const menuButton=document.querySelector(".menu-button");
const menu=document.querySelector(".site-menu");
menuButton?.addEventListener("click",()=>{
  const open=menu.classList.toggle("open");
  menuButton.setAttribute("aria-expanded",String(open));
});
document.querySelectorAll(".site-menu a").forEach(a=>a.addEventListener("click",()=>{
  menu.classList.remove("open");
  menuButton?.setAttribute("aria-expanded","false");
}));

const revealObserver=new IntersectionObserver(entries=>{
  entries.forEach(entry=>{
    if(entry.isIntersecting){
      entry.target.classList.add("visible");
      revealObserver.unobserve(entry.target);
    }
  });
},{threshold:.12});
document.querySelectorAll(".reveal").forEach(el=>revealObserver.observe(el));

const details={
 platform:{kicker:"Core platform",title:"Cloud Platform",text:"A governed Microsoft cloud foundation brings identity, networking, security, endpoint management and automation together.",items:["Clear operational ownership","Security and governance by design","Scalable service delivery"]},
 identity:{kicker:"Identity layer",title:"Microsoft Entra ID",text:"Identity controls provide the foundation for secure access across users, devices, applications and cloud resources.",items:["Conditional Access","Least-privilege administration","Authentication and lifecycle controls"]},
 endpoint:{kicker:"Device management",title:"Microsoft Intune",text:"Modern endpoint management helps keep devices configured, compliant and supportable wherever users work.",items:["Configuration and compliance","Application deployment","Proactive remediation"]},
 security:{kicker:"Threat protection",title:"Microsoft Defender",text:"Connected security signals improve visibility across endpoints, identities, email, applications and cloud workloads.",items:["Endpoint protection","Incident visibility","Security posture improvement"]},
 automation:{kicker:"Operational efficiency",title:"PowerShell Automation",text:"Reusable scripts and controlled workflows reduce repetitive effort and improve consistency across administrative tasks.",items:["Repeatable operations","Audit-friendly execution","Sanitised public examples"]},
 network:{kicker:"Cloud connectivity",title:"Azure Networking",text:"Secure connectivity, name resolution and traffic control are essential parts of a reliable cloud platform.",items:["Hub-and-spoke design","Private connectivity","DNS and routing"]},
};
const title=document.getElementById("detail-title");
const text=document.getElementById("detail-text");
const kicker=document.getElementById("detail-kicker");
const list=document.getElementById("detail-list");
document.querySelectorAll(".topology-node").forEach(btn=>{
  btn.addEventListener("click",()=>{
    document.querySelectorAll(".topology-node").forEach(x=>x.classList.remove("active"));
    btn.classList.add("active");
    const d=details[btn.dataset.key];
    kicker.textContent=d.kicker;title.textContent=d.title;text.textContent=d.text;
    list.innerHTML=d.items.map(x=>`<li>${x}</li>`).join("");
  });
});

const scene=document.getElementById("cloud-scene");
if(scene && !matchMedia("(prefers-reduced-motion: reduce)").matches){
  scene.addEventListener("pointermove",e=>{
    const r=scene.getBoundingClientRect();
    const x=(e.clientX-r.left)/r.width-.5;
    const y=(e.clientY-r.top)/r.height-.5;
    scene.style.transform=`rotateY(${x*5}deg) rotateX(${-y*4}deg)`;
  });
  scene.addEventListener("pointerleave",()=>scene.style.transform="");
}

const sections=[...document.querySelectorAll("main section[id],header[id]")];
const navLinks=[...document.querySelectorAll(".site-menu a")];
const navObserver=new IntersectionObserver(entries=>{
  entries.forEach(entry=>{
    if(entry.isIntersecting){
      navLinks.forEach(a=>a.classList.toggle("active",a.getAttribute("href")===`#${entry.target.id}`));
    }
  });
},{rootMargin:"-45% 0px -45% 0px"});
sections.forEach(s=>navObserver.observe(s));
document.getElementById("year").textContent=new Date().getFullYear();
