--created by Walrus, coded by Lyris
--Voidictator Rune - Unstable Gating Art
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	c:SetUniqueOnField(1,0,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(s.condition(s.rcfilter))
	e3:SetCost(s.cost(2,s.sfilter))
	e3:SetTarget(s.tg(LOCATION_DECK+LOCATION_HAND))
	e3:SetOperation(s.op(LOCATION_DECK+LOCATION_HAND))
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCountLimit(1,id+200)
	e4:SetCondition(s.condition(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA)))
	e4:SetCost(s.cost(3))
	e4:SetTarget(s.tg(LOCATION_EXTRA))
	e4:SetOperation(s.op(LOCATION_EXTRA))
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,id+200)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCondition(function(e) local re=e:GetHandler():GetReasonEffect() return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
end
function s.descon(e)
	return not Duel.IsEnvironment(id-15)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSummonType),tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSummonType),tp,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)*500,REASON_EFFECT)
end
function s.rcfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.condition(f)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				local typ=0
				for tc in aux.Next(eg) do if tc:GetSummonPlayer()~=tp then typ=typ|tc:GetType()&TYPE_EXTRA+TYPE_RITUAL end end
				e:SetLabel(typ)
				return typ>0 and eg:IsExists(f,1,nil)
			end
end
function s.sfilter(c)
	return c:IsSetCard(0x3c97) and c:IsLevel(4)
end
function s.cfilter(c,f)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc97) and c:IsAbleToRemoveAsCost() and (not f or f(c))
end
function s.cost(ct,f)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,ct,nil,f) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,ct,ct,nil,f),POS_FACEUP,REASON_COST)
			end
end
function s.filter(c,e,tp)
	local typ=e:GetLabel()
	if typ&TYPE_XYZ>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return false end
	return c:IsType(typ) and c:IsSetCard(0xc97) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and (typ&TYPE_EXTRA>0 and c:IsSetCard(0x6c97,0x9c97) and Duel.GetLocationCountFromEx(tp)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.tg(loc)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,loc,0,1,nil,e,tp) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
			end
end
function s.op(loc)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tc=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,nil,e,tp):GetFirst()
				if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CANNOT_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.GetTurnPlayer()==tp and 2 or 1)
					tc:RegisterEffect(e1)
				end
				if Duel.SpecialSummonComplete()==1 and tc:IsType(TYPE_XYZ) then
					Duel.BreakEffect()
					Duel.DisableShuffleCheck()
					Duel.Overlay(tc,Duel.GetDecktopGroup(tp,2))
				end
			end
end
