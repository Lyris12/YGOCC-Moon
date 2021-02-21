--Shya Citadel
function c11000510.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c11000510.tg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	--self destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(c11000510.descon)
	c:RegisterEffect(e4)
	--sending
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11000510,0))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c11000510.ctcon)
	e5:SetTarget(c11000510.target)
	e5:SetOperation(c11000510.activate)
	c:RegisterEffect(e5)
end
function c11000510.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1FD) and not c:IsCode(11000510)
end
function c11000510.descon(e)
	return not Duel.IsExistingMatchingCard(c11000510.filter,e:GetHandler():GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c11000510.tg(e,c)
	return c:IsSetCard(0x1FD) and c:IsType(TYPE_MONSTER)
end
function c11000510.cfilter(c)
	return c:IsSetCard(0x1FD) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c11000510.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11000510.cfilter,1,nil)
end
function c11000510.tgfilter(c)
	return c:IsSetCard(0x1FD) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c11000510.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11000510.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c11000510.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c11000510.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end