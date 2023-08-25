--created by LeonDuvall, coded by Lyris
--Concentrating Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetDescription(1108)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
Card.IsConcentratedMagitate=Card.IsConcentratedMagitate or function(c) return c:GetCode()>131792009 and c:GetCode()<131792017 and c:IsSetCard(0xd16) end
function s.drcon(e)
	return e:GetHandler():IsPreviousControler(tp) and e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.filter(c)
	return Card.IsConcentratedMagitate and c:IsConcentratedMagitate() and c:IsAbleToRemove()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.Remove(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil),POS_FACEUP,REASON_EFFECT)<1 then Duel.Draw(tp,1,REASON_EFFECT) end
end
