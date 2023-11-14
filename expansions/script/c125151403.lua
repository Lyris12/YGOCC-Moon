--created by LeonDuvall, coded by Lyris
--Exodice Fiche
local s,id,o=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.pscost)
	e1:SetTarget(s.pstg)
	e1:SetOperation(s.psop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sfilter(c,e,tp)
	return c:IsSetCard(0xd18) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.spop(e,tp)
	if Duel.Damage(1-tp,100,REASON_EFFECT)<1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.cfilter(c)
	return c:IsRace(RACE_FISH) and c:IsDiscardable()
end
function s.pscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST)
end
function s.filter(c,tp)
	local e=c:GetActivateEffect()
	local evt=e:GetCode()
	return c:IsSetCard(0xd18) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsType(TYPE_FIELD)
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:CheckActivateEffect(false,false)
		and evt==EVENT_FREE_CHAIN and e:IsActivatable(tp)
end
function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	if tc:IsType(TYPE_FIELD) then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	else Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
	local c=e:GetHandler()
	local te=tc:GetActivateEffect()
	te:UseCountLimit(tp,1,true)
	local tep=tc:GetControler()
	c:SetEntityCode(tc:GetOriginalCode(),true)
	Duel.ClearTargetCard()
	local cost=te:GetCost()
	if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	local trg=te:GetTarget()
	if trg then trg(te,tep,eg,ep,ev,re,r,rp,1)
	local op=te:GetOperation()
	if op then
		tc:CreateEffectRelation(te)
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:GetFirst()
		while tg do
			tg:CreateEffectRelation(te)
			tg=g:GetNext()
		end
		op(te,tep,eg,ep,ev,re,r,rp)
		tc:ReleaseEffectRelation(te)
		tg=g:GetFirst()
		while tg do
			tg:ReleaseEffectRelation(te)
			tg=g:GetNext()
		end
	end
	c:SetEntityCode(id)
	tc:CancelToGrave(false)
end
