--created by Seth, coded by Lyris
--Shadow NOVA - Dartylochi
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1f),2,false)
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function() return not c:IsLocation(LOCATION_EXTRA) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target(LOCATION_DECK))
	e2:SetOperation(s.operation(LOCATION_DECK))
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*10)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(aux.exccon)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id+o*20)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetCondition(function() return c:IsSummonLocation(LOCATION_GRAVE) end)
	e4:SetTarget(s.target(LOCATION_GRAVE))
	e4:SetOperation(s.operation(LOCATION_GRAVE))
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND+LOCATION_DECK,0,nil,0xe1f)
	if chk==0 then return g:GetClassCount(Card.GetLocation)>1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g:SelectSubGroup(tp,function(tg) return tg:GetClassCount(Card.GetLocation)==#tg end,false,2,2,tp),REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0xe1f) and c:IsAbleToHand()
end
function s.target(loc)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,loc,0,1,nil) end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
			end
end
function s.operation(loc)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,nil)
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
end
function s.cfilter(c)
	return c:IsSetCard(0xe1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,c)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,c)
	if Duel.SendtoDeck(g,2,nil,REASON_EFFECT)<2
		or g:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_DECK+LOCATION_EXTRA) or not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
