--Dorein Celebrazione
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--count damage
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-ep then
		s[rp]=s[rp]+ev
	end
end
function s.damchk(val)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then tp=e:GetHandlerPlayer() end
				return s[tp]>=val
			end
end

function s.filter(c,e,tp)
	return c:NotBanishedOrFaceup() and c:IsSetCard(0xd04) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		--
		local b1=Duel.GetLP(1-tp)>=3000 and s.damchk(1000)(e,tp)
		local b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and s.damchk(2000)(e,tp)
		local b3=Duel.IsExistingMatchingCard(s.rmf,tp,0,LOCATION_MZONE,1,nil) and s.damchk(3000)(e,tp)
		if b1 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,1000,REASON_EFFECT)
			b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and s.damchk(2000)(e,tp)
			b3=Duel.IsExistingMatchingCard(s.rmf,tp,0,LOCATION_MZONE,1,nil) and s.damchk(3000)(e,tp)
		end
		if b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
			local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Negate(g:GetFirst(),e,RESET_PHASE+PHASE_END)
				Duel.AdjustInstantly(g:GetFirst())
			end
			b3=Duel.IsExistingMatchingCard(s.rmf,tp,0,LOCATION_MZONE,1,nil) and s.damchk(3000)(e,tp)
		end
		if b3 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,s.rmf,tp,0,LOCATION_MZONE,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
function s.rmf(c)
	return (c:IsFacedown() or c:IsMonster()) and c:IsAbleToRemove()
end