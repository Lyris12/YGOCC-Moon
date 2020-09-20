--Secondary Stats
local m=8886600
local cm=_G["c"..m]
function cm.initial_effect(c)
--  Label Effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1)
	e0:SetCondition(cm.startcon)
	e0:SetOperation(cm.start)
	c:RegisterEffect(e0)
--  Critical

--  vers
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(0,1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetValue(cm.versitilityval1)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetTargetRange(1,0)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetValue(cm.versitilityval2)
	c:RegisterEffect(e3)
--  haste
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCondition(cm.condition)
	e4:SetTarget(cm.target)
	e4:SetOperation(cm.activate)
	c:RegisterEffect(e4)
--  Mastery Example
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_EXTRA)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetValue(cm.e5value)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	--set STAT to x amount

	local ae2=Effect.CreateEffect(c)
	ae2:SetDescription(aux.Stringid(m,1))
	ae2:SetType(EFFECT_TYPE_IGNITION)
	ae2:SetRange(LOCATION_EXTRA)
	ae2:SetOperation(cm.ae2op)
	c:RegisterEffect(ae2)
	local ae3=Effect.CreateEffect(c)
	ae3:SetDescription(aux.Stringid(m,2))
	ae3:SetType(EFFECT_TYPE_IGNITION)
	ae3:SetRange(LOCATION_EXTRA)
	ae3:SetOperation(cm.ae3op)
	c:RegisterEffect(ae3)
	local ae4=Effect.CreateEffect(c)
	ae4:SetDescription(aux.Stringid(m,3))
	ae4:SetType(EFFECT_TYPE_IGNITION)
	ae4:SetRange(LOCATION_EXTRA)
	ae4:SetOperation(cm.ae4op)
	c:RegisterEffect(ae4)
	
end

function cm.ae2op(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190)
	Duel.SetFlagEffectLabel(tp,88866001,lv)
end

function cm.ae3op(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100)
	Duel.SetFlagEffectLabel(tp,88866002,lv)
end

function cm.ae4op(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.AnnounceNumber(tp,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190)
	Duel.SetFlagEffectLabel(tp,88866003,lv)
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
	-- Critical Strike
	Duel.RegisterFlagEffect(tp,88866000,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866000,10)
	-- Versitility
	Duel.RegisterFlagEffect(tp,88866001,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866001,100)
	-- Haste
	Duel.RegisterFlagEffect(tp,88866002,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866002,30)
	-- Mastery
	Duel.RegisterFlagEffect(tp,88866003,RESET_DISABLE,0,1)
	Duel.SetFlagEffectLabel(tp,88866003,10)
	--  To Extra - Face-up
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end

--Critical-- 

function cm.critcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if ep~=tp then return false end
	local critchance=Duel.GetFlagEffectLabel(tp,88866000)
	local check = math.ceil(math.random() * 100)
	return check < critchance
end

function cm.critop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Damage(1-tp,ev*0.5,REASON_RULE)
	Duel.RaiseSingleEvent(c,EVENT_CUSTOM+8886600,re,0,0,p,0)
end

--Versitility--

function cm.versitilityval1(e,re,dam,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local vers = Duel.GetFlagEffectLabel(tp,88866001)
	return dam * (1 + (vers * 0.01))
end

function cm.versitilityval2(e,re,dam,r,rp,rc)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local vers = Duel.GetFlagEffectLabel(tp,88866001)
	if vers >= 200 then vers = 199 end
	return dam * (1 - (vers * 0.005))
end

--  Haste


function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local hastechance=Duel.GetFlagEffectLabel(tp,88866002)
	local check = math.ceil(math.random() * 100)
	return check < hastechance and rp==tp
end


function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ftg=re:GetTarget()
	if chkc then return ftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk) end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local fop=re:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end
