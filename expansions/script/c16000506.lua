--Daddou, Final Mage of Magnificent VINE 
function c16000506.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x85a),2)
	c:EnableReviveLimit()

   --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c16000506.chainop)
	c:RegisterEffect(e1)
  --special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16000506,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c16000506.spcon)
	e2:SetTarget(c16000506.target2)
	e2:SetOperation(c16000506.activate2)
	c:RegisterEffect(e2)

local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16000506,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c16000506.matcost)
	e5:SetTarget(c16000506.mattg)
	e5:SetOperation(c16000506.matop)
	c:RegisterEffect(e5)
end

function c16000506.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if  rc:IsSetCard(0x285a)  then
		Duel.SetChainLimit(c16000506.chainlm)
	end
end
function c16000506.chainlm(e,rp,tp)
	return tp==rp
end
function c16000506.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x85a)  and c:IsAbleToHand()
end
function c16000506.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c16000506.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c16000506.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16000506.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c16000506.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function c16000506.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
function c16000506.tgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x285a)
end
function c16000506.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c16000506.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and not c:IsType(TYPE_TOKEN)
end
function c16000506.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16000506.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16000506.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c16000506.matfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c16000506.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c16000506.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c16000506.matfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end