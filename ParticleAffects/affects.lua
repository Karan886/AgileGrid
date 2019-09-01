local affects = {}

affects.smokeExplosion = {
    startColorAlpha = 0.5,
    startParticleSizeVariance = 0,
    blendFuncSource = 775,
    particleLifespan = 0.5,
    blendFuncDestination = 1,
    startParticleSize = 70,
    endParticleSize = 20,
    textureFileName = "Images/Particles/GreyCircle.png",
    maxParticles = 800,
    duration = 0.2,
    speed = 300,
    angleVariance = 360,
    angle = 360,
    finishColorRed = 1.0,
    finishColorGreen = 1.0,
    finishColorBlue = 1.0
}

affects.sprinkles = {
    startColorAlpha = 1.0,
    startParticleSizeVariance = 0,
    blendFuncSource = 775,
    particleLifespan = 0.4,
    blendFuncDestination = 1,
    startParticleSize = 8,
    textureFileName = "Images/Particles/yellow_square.png",
    endParticleSize = 15,
    maxParticles = 2000,
    duration = 0.05,
    speed = 300,
    angleVariance = 180,
    angle = 270,
    finishColorRed = 0.93,
    finishColorGreen = 0.93,
    finishColorBlue = 0.0
}
return affects