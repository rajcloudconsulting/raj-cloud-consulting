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


const techScene=document.getElementById("tech-scene");
const techCanvas=document.getElementById("tech-canvas");

if(techScene && techCanvas){
  const ctx=techCanvas.getContext("2d");
  const reduceMotion=matchMedia("(prefers-reduced-motion: reduce)").matches;
  let width=0,height=0,dpr=1,particles=[],links=[],mouse={x:0,y:0,active:false};

  function resizeTechCanvas(){
    const rect=techScene.getBoundingClientRect();
    dpr=Math.min(window.devicePixelRatio||1,2);
    width=Math.max(1,Math.round(rect.width));
    height=Math.max(1,Math.round(rect.height));
    techCanvas.width=Math.round(width*dpr);
    techCanvas.height=Math.round(height*dpr);
    ctx.setTransform(dpr,0,0,dpr,0,0);
    createNetwork();
  }

  function createNetwork(){
    const count=width<520?34:68;
    particles=Array.from({length:count},(_,i)=>({
      x:Math.random()*width,
      y:Math.random()*height,
      z:.25+Math.random()*.75,
      vx:(Math.random()-.5)*.18,
      vy:(Math.random()-.5)*.18,
      r:.7+Math.random()*1.5,
      phase:Math.random()*Math.PI*2
    }));
    links=[];
    for(let i=0;i<particles.length;i++){
      for(let j=i+1;j<particles.length;j++){
        const dx=particles[i].x-particles[j].x;
        const dy=particles[i].y-particles[j].y;
        if(dx*dx+dy*dy < (width<520?6200:9200)) links.push([i,j]);
      }
    }
  }

  function drawTech(time=0){
    ctx.clearRect(0,0,width,height);
    const cx=width*.5,cy=height*.48;

    const globeRadius=Math.min(width,height)*.28;
    ctx.save();
    ctx.translate(cx,cy);
    ctx.strokeStyle="rgba(67,191,255,.10)";
    ctx.lineWidth=1;
    for(let i=-3;i<=3;i++){
      const rx=globeRadius*Math.cos(i*.18);
      ctx.beginPath();
      ctx.ellipse(0,0,Math.max(8,Math.abs(rx)),globeRadius,0,0,Math.PI*2);
      ctx.stroke();
    }
    for(let i=-2;i<=2;i++){
      const ry=globeRadius*Math.cos(i*.35);
      ctx.beginPath();
      ctx.ellipse(0,0,globeRadius,Math.max(8,Math.abs(ry)),0,0,Math.PI*2);
      ctx.stroke();
    }
    ctx.restore();

    ctx.lineWidth=.65;
    links.forEach(([a,b])=>{
      const p=particles[a],q=particles[b];
      const alpha=.04+.08*Math.min(p.z,q.z);
      ctx.strokeStyle=`rgba(67,194,255,${alpha})`;
      ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(q.x,q.y);ctx.stroke();
    });

    particles.forEach((p,i)=>{
      if(!reduceMotion){
        p.x+=p.vx*p.z;p.y+=p.vy*p.z;
        if(p.x<0)p.x=width;if(p.x>width)p.x=0;
        if(p.y<0)p.y=height;if(p.y>height)p.y=0;
      }
      const pulse=.65+.35*Math.sin(time*.0015+p.phase);
      ctx.fillStyle=`rgba(102,221,255,${.35+.45*p.z})`;
      ctx.beginPath();ctx.arc(p.x,p.y,p.r*pulse,0,Math.PI*2);ctx.fill();

      if(mouse.active){
        const dx=p.x-mouse.x,dy=p.y-mouse.y,d=Math.hypot(dx,dy);
        if(d<110){
          ctx.strokeStyle=`rgba(112,232,255,${(1-d/110)*.28})`;
          ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(mouse.x,mouse.y);ctx.stroke();
        }
      }
    });

    requestAnimationFrame(drawTech);
  }

  techScene.addEventListener("pointermove",e=>{
    const r=techScene.getBoundingClientRect();
    mouse.x=e.clientX-r.left;mouse.y=e.clientY-r.top;mouse.active=true;
    if(!reduceMotion){
      const x=mouse.x/r.width-.5,y=mouse.y/r.height-.5;
      techScene.style.setProperty("--tilt-x",`${-y*2.5}deg`);
      techScene.style.setProperty("--tilt-y",`${x*3}deg`);
    }
  });
  techScene.addEventListener("pointerleave",()=>{
    mouse.active=false;
    techScene.style.removeProperty("--tilt-x");
    techScene.style.removeProperty("--tilt-y");
  });

  new ResizeObserver(resizeTechCanvas).observe(techScene);
  resizeTechCanvas();
  requestAnimationFrame(drawTech);
}
