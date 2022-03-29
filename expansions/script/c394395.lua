--Dorein Ricerca Rischiarata dalla Luna
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
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
	if not re then return end
	local rc=re:GetHandler()
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-ep and rc and rc:IsSetCard(0xd04) then
		s[rp]=s[rp]+ev
	end
end
function s.damchk(val)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if not tp then tp=e:GetHandlerPlayer() end
				return s[tp]>=val
			end
end

function s.filter(c)
	return c:IsSetCard(0xd04) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(aux.PLChk,1,nil,tp,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		--
		local b1=g:GetFirst():GetLevel()>0 and s.damchk(1000)(e,tp)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,394400,0xd04,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_FIRE) and s.damchk(2000)(e,tp)
		local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_HAND,0,1,nil,e,tp,g:GetFirst():GetCode()) and s.damchk(3000)(e,tp)
		local flag=0
		if b1 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			flag=Duel.Damage(1-tp,g:GetFirst():GetLevel()*100,REASON_EFFECT)
			b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,394400,0xd04,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_FIRE) and s.damchk(2000)(e,tp)
			b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_HAND,0,1,nil,e,tp,g:GetFirst():GetCode()) and s.damchk(3000)(e,tp)
		end
		if b2 and flag>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local token=Duel.CreateToken(tp,394400)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(flag)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE)
			e2:SetValue(flag)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e2)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_HAND,0,1,nil,e,tp,g:GetFirst():GetCode()) and s.damchk(3000)(e,tp)
		end
		if b3 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.spf,tp,LOCATION_HAND,0,1,1,nil,e,tp,g:GetFirst():GetCode())
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spf(c,e,tp,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd04) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end