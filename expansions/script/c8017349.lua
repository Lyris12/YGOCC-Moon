--Vocaliases Entreé
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cid.spcost)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
--Activate
--filters
function cid.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
function cid.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(6) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,id,tp,false,false)
end
function cid.opposp(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,id,tp,false,false)
end
function cid.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and e:GetHandler()~=re:GetHandler() and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+id)
end
function cid.nfilter(c)
	return c:IsLevelBelow(4) and c:IsSummonable(true,nil)
end
---------
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local p=Duel.GetTurnPlayer()
		if p==tp then
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>1 
			and not Duel.IsPlayerAffectedByEffect(1-tp,59822133)
			and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(cid.opposp,tp,0,LOCATION_DECK,2,nil,e,1-tp)
		else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(cid.nfilter,tp,LOCATION_HAND,0,2,nil)
		end
	end
	local p=Duel.GetTurnPlayer()
	e:SetCategory((CATEGORY_SPECIAL_SUMMON+CATEGORY_SUMMON)|e:GetCategory())
	e:SetLabel(0)
	if p==tp then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(100)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			e:SetLabelObject(g:GetFirst())
			g:GetFirst():CreateEffectRelation(e)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
		end
	else
		e:SetCategory(CATEGORY_SUMMON)
		e:SetLabel(200)
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,2,tp,LOCATION_HAND)
	end
end			
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	if p==100 then
		local sc=e:GetLabelObject()
		if not sc or not sc:IsRelateToEffect(e) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(1-tp,59822133) then return end
		local lv={0,0}
		local ct=0
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(1-tp,cid.opposp,tp,0,LOCATION_DECK,2,2,nil,e,1-tp)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				if Duel.SpecialSummonStep(tc,id,1-tp,1-tp,false,false,POS_FACEUP) then
					ct=ct+1
					lv[ct]=tc:GetLevel()
					local e0=Effect.CreateEffect(e:GetHandler())
					e0:SetType(EFFECT_TYPE_SINGLE)
					e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
					e0:SetRange(LOCATION_MZONE)
					e0:SetCode(EFFECT_IMMUNE_EFFECT)
					e0:SetReset(RESET_EVENT+RESETS_STANDARD)
					e0:SetValue(cid.efilter)
					tc:RegisterEffect(e0,true)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
					e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
					e1:SetValue(LOCATION_REMOVED)
					tc:RegisterEffect(e1,true)
				end
				Duel.SpecialSummonComplete()
				tc=g:GetNext()
			end
		end
		Duel.BreakEffect()
		if g:GetFirst():IsFaceup() and lv[1]~=sc:GetLevel() and lv[2]~=sc:GetLevel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and sc:IsCanBeSpecialSummoned(e,id,tp,false,false) then
			if Duel.SpecialSummonStep(sc,id,tp,tp,false,false,POS_FACEUP) then
				local e0=Effect.CreateEffect(e:GetHandler())
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e0:SetRange(LOCATION_MZONE)
				e0:SetCode(EFFECT_IMMUNE_EFFECT)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				e0:SetValue(cid.efilter)
				sc:RegisterEffect(e0,true)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				sc:RegisterEffect(e1,true)
			end
			Duel.SpecialSummonComplete()
		end
	elseif p==200 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.nfilter,tp,LOCATION_HAND,0,2,2,nil)
		local tc=g:GetFirst()
		while tc do
			Duel.Summon(tp,tc,true,nil)
			tc=g:GetNext()
		end
		local og=g:Filter(Card.IsOnField,nil)
		if #og<2 or og:GetClassCount(Card.GetRace)>1 or og:GetClassCount(Card.GetAttribute)>1 then
			local oc=og:GetFirst()
			while oc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				oc:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				oc:RegisterEffect(e2,true)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK_FINAL)
				e3:SetValue(0)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				oc:RegisterEffect(e3,true)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
				oc:RegisterEffect(e4,true)
				oc=og:GetNext()
			end
		end
	else
		return
	end
end						
				