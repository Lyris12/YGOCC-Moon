--created & coded by Lyris, art at https://www.reddit.com/r/yugioh/comments/d8rrf9/crusadia_maximus/
--機氷竜マクシー
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(2,id)
	e1:SetCondition(function() return c:IsPublic() end)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	e1:SetValue(aux.TargetBoolFunction(s.filter,c:GetControler()))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o*10)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetCondition(function(e,tp) local ex,eg,ep,ev,re,r,rp=Duel.CheckEvent(EVENT_CHAINING,true)
	return aux.bpcon() and (not ex or rp==tp) end)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return aux.bpcon() and rp~=tp end)
	c:RegisterEffect(e3)
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0xd76)
		and not c:IsReason(REASON_REPLACE)
end
function s.cfilter(c)
	return c:IsSetCard(0xd76) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	Duel.Hint(HINT_CARD,0,id)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	s.atkup(Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil))(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.atkup(Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)))
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then Duel.Destroy(rc,REASON_EFFECT) end
end
function s.atkup(g)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				g:ForEach(function(tc)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					e1:SetValue(1000)
					tc:RegisterEffect(e1)
				end)
			end
end
