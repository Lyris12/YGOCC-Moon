--created by LeonDuvall, coded by Lyris
--Verdant Concentrated Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_REMOVED)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
Card.IsConcentratedMagitate=Card.IsConcentratedMagitate or function(c) return c:GetCode()>131792009 and c:GetCode()<131792017 and c:IsSetCard(0xd16) end
function s.mfilter(c)
	return c:IsLevelBelow(4) and not c:IsLinkAttribute(ATTRIBUTE_EARTH) and c:IsSetCard(0xd16)
end
function s.cfilter(c)
	return (not c:IsPreviousLocation(LOCATION_ONFIELD) or c:IsPreviousPosition(POS_FACEUP))
		and c:GetPreviousLevelOnField()==5 and c:IsPreviousSetCard(0xd16)
end
function s.con(e,tp,eg)
	return eg:FilterCount(s.cfilter,nil)==1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
function s.tdop(e,tp)
	Duel.SendtoDeck(Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
