--VECTOR Frame Eska II
--Scripted by Zerry
function c67864643.initial_effect(c)
--link summon
	 aux.AddLinkProcedure(c,c67864643.lfilter,1,1)
	c:EnableReviveLimit()
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,67864643+100)
	e2:SetCondition(c67864643.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c67864643.negtg)
	e2:SetOperation(c67864643.negop)
	c:RegisterEffect(e2)
local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(67864662,0))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,67864643)
	e5:SetCondition(c67864643.tgcon)
	e5:SetTarget(c67864643.tgtg)
	e5:SetOperation(c67864643.tgop)
	c:RegisterEffect(e5)
end
function c67864643.lmfilter(c)
	return c:IsLinkSetCard(0x2a6) and not c:IsType(TYPE_LINK)
end
function c67864643.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c67864643.tgfilter(c)
	return c:IsSetCard(0x2a6) and c:IsAbleToGrave()
end
function c67864643.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864643.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c67864643.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c67864643.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c67864643.spfilter1(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function c67864643.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and rp==1-tp and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c67864643.spfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function c67864643.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c67864643.negop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.NegateEffect(ev)
end