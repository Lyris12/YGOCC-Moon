--created by Discord \ Walrus, coded by Lyris, art from "Supreme King Z-ARC"
--虚空制裁者悪魔アンフォームド・マレボルンス
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0xc97),1,99,s.mfilter,1,99)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(3)
	e1:SetCondition(s.cpcon)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetCondition(s.retcon)
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	e4:SetCondition(s.rrtcon)
	c:RegisterEffect(e4)
end
s.spt_other_space=102400178
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPATIAL) and c:IsSummonPlayer(tp)
end
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.cfilter,nil,1-tp)==1
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:Filter(s.cfilter,nil,1-tp):GetFirst())
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		e:GetHandler():CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsExtraDeckMonster() and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA)) then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.BreakEffect()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then for tc in aux.Next(g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end end
	end
end
function s.rrtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rf=c:GetReasonEffect()
	local rc=rf and rf:GetHandler() or c:GetReasonCard()
	return rc and rc:IsSetCard(0xc97) and rc:GetOwner()==tp
end
