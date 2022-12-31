--Kataria, Tower Girl of Evil Vine
function c500311420.initial_effect(c)
c:SetUniqueOnField(1,0,500311420)
aux.AddSynchroProcedure(c,aux.FilterBoolFunction(c500311420.synfilter),aux.NonTuner(c500311420.synfilter2),2)
	c:EnableReviveLimit()
		--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c500311420.immcon)
	e1:SetValue(c500311420.efilter)
	c:RegisterEffect(e1)
		--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(c500311420.cost)
	e2:SetTarget(c500311420.target)
	e2:SetOperation(c500311420.operation)
	c:RegisterEffect(e2)
	--cannot special summon: Here's something to shut you the fuck up!
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.synlimit)
	c:RegisterEffect(e3)
end

function c500311420.synfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
function c500311420.synfilter2(c)
	return  c:IsSetCard(0x485a)
end
function c500311420.immcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c500311420.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
function c500311420.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
function c500311420.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c500311420.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c500311420.costfilter,1,1,REASON_EFFECT+REASON_DISCARD)
end
function c500311420.filter(c)
		return c:IsDestructable() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c500311420.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c500311420.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c500311420.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c500311420.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c500311420.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
