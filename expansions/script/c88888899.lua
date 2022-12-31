--Augment: Nightknight
local m=88888899
local cm=c88888899

function cm.initial_effect(c)
	--  act
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0a:SetCode(EVENT_PREDRAW)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e0a:SetOperation(cm.start)
	c:RegisterEffect(e0a)
	--atk boost
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_UPDATE_ATTACK)
	pe1:SetRange(LOCATION_EXTRA)
	pe1:SetTargetRange(LOCATION_MZONE,0)
	pe1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xff9b))
	pe1:SetValue(cm.atkvalue)
	c:RegisterEffect(pe1)
	local pe2=pe1:Clone()
	pe2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(pe2) 
	local pe3=pe1:Clone()
	pe3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xff9a))
	c:RegisterEffect(pe3) 
	local pe4=pe3:Clone()
	pe4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(pe4) 
--  Generation

	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4a:SetRange(LOCATION_EXTRA)
	e4a:SetProperty(EFFECT_FLAG_DELAY)
	e4a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4a:SetCondition(cm.bgeye4drcon1)
	e4a:SetOperation(cm.bgeye4drop1)
	c:RegisterEffect(e4a)

	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4b:SetRange(LOCATION_EXTRA)
	e4b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4b:SetCondition(cm.bgeye4regcon)
	e4b:SetOperation(cm.bgeye4regop)
	c:RegisterEffect(e4b)

	local e4c=Effect.CreateEffect(c)
	e4c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4c:SetCode(EVENT_CHAIN_SOLVED)
	e4c:SetRange(LOCATION_EXTRA)
	e4c:SetCondition(cm.bgeye4drcon2)
	e4c:SetOperation(cm.bgeye4drop2)
	c:RegisterEffect(e4c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(cm.aug3con)
	e1:SetTarget(cm.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(cm.aug5con)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.activate)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetCondition(cm.aug8con)
	e3:SetTarget(cm.etarget)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1)
	e4:SetOperation(cm.damop)
	c:RegisterEffect(e4)
end

--start

function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end

--generation

function cm.bgeye4filter(c,sp)
	return (c:IsSetCard(0xff9a) or c:IsSetCard(0xff9b)) 
end

function cm.bgeye4drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.bgeye4filter,1,nil,1-tp)
		and (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end

function cm.bgeye4drop1(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetOwner()
	local dr=Duel.GetFlagEffect(tp,m)
	local max=4
	if dr>max then dr=4 end
	local inc= 10 - (dr*2)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	Duel.GainAugment(tp,inc)
end

function cm.bgeye4regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.bgeye4filter,1,nil,1-tp)
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end

function cm.bgeye4regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,888888888,RESET_CHAIN,0,1)
end

function cm.bgeye4drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,888888888)>0
end

function cm.bgeye4drop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,888888888)
	local tp=e:GetHandlerPlayer()
	local dr=Duel.GetFlagEffect(tp,m)
	local max=4
	if dr>max then dr=4 end
	local inc= 10 - (dr*2)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	Duel.GainAugment(tp,inc)
end


--atkgain

function cm.atkvalue(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local aug = Duel.GetAugment(tp)
	return aug * 10
end

--30 

function cm.aug3con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local aug = Duel.GetAugment(tp)
	local threshold=30
	return aug >= threshold
end

function cm.indtg(e,c)
	return (c:IsSetCard(0xff9a) or c:IsSetCard(0xff9b))
end

--50 

function cm.aug5con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local aug = Duel.GetAugment(tp)
	local threshold=50
	return aug >= threshold
end

function cm.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c:IsSetCard(0xff9a)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--80

function cm.aug8con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	local aug = Duel.GetAugment(tp)
	local threshold=80
	return aug >= threshold
end

function cm.etarget(e,c)
	return c:IsSetCard(0xff9a)
end
function cm.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--

function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local new = math.floor(Duel.GetAugment(tp) * 0.8)
	return Duel.SetAugment(tp,new)
end
