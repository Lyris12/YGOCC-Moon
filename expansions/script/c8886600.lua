--Secondary Stats
local m=8886600
local cm=_G["c"..m]
function cm.initial_effect(c)
--  vers
	aux.EnableUtil(c)
--  haste
	aux.EnableHaste(c)
--  Label Effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e0:SetCondition(cm.startcon)
	e0:SetOperation(cm.start)
	c:RegisterEffect(e0)
	--set STAT to x amount

	local ae2=Effect.CreateEffect(c)
	ae2:SetDescription(aux.Stringid(m,1))
	ae2:SetType(EFFECT_TYPE_IGNITION)
	ae2:SetRange(LOCATION_EXTRA)
	ae2:SetCountLimit(3)
	ae2:SetOperation(cm.ae2op)
	c:RegisterEffect(ae2)
	local ae3=Effect.CreateEffect(c)
	ae3:SetDescription(aux.Stringid(m,2))
	ae3:SetType(EFFECT_TYPE_IGNITION)
	ae3:SetRange(LOCATION_EXTRA)
	ae3:SetCountLimit(3)
	ae3:SetOperation(cm.ae3op)
	c:RegisterEffect(ae3)
	local ae4=Effect.CreateEffect(c)
	ae4:SetDescription(aux.Stringid(m,3))
	ae4:SetType(EFFECT_TYPE_IGNITION)
	ae4:SetRange(LOCATION_EXTRA)
	ae4:SetCountLimit(3)
	ae4:SetOperation(cm.ae4op)
	c:RegisterEffect(ae4)
	
end

function cm.ae2op(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200)
	Duel.SetUtil(tp, lv)
	Debug.Message(Duel.GetUtil(tp))
end

function cm.ae3op(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200)
	Duel.SetHaste(tp, lv)
end

function cm.ae4op(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200)
	Duel.SetAugment(tp, lv)
end

function cm.e5value(e,re,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local mast = Duel.GetFlagEffectLabel(tp,88866003)
	return (25*mast)
end
	
--Init--

function cm.startcon(e,tp,eg,ep,ev,re,r,rp)
		return (Duel.GetFlagEffect(tp,88866000) < 1)
end

function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end
