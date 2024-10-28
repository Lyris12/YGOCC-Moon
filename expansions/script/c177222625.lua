--Bigbang Metamorphosis
local s,id,o=GetID()
function s.initial_effect(c)
	--Target 1 face-up monster you control; Destroy it, and if you do, Special Summon from your Deck 1 monster with the same original Type and Attribute that destroyed monster had on the field, but with a different original Vibe
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:HasVibe() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,tc)
	return s.GetOriginalVibe(c) ~=s.GetOriginalVibe(tc)
		and c:IsRace(tc:GetOriginalRace())
		and c:IsAttribute(tc:GetOriginalAttribute())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_BIGBANG) and c:IsLocation(LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		if #g>0 then
			local sc=g:GetFirst()
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
				--also you cannot Special Summon monsters from the Extra Deck, except Bigbang Monsters, while you control that face-up monster.
				local e1=Effect.CreateEffect(sc)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetAbsoluteRange(tp,1,0)
				e1:SetTarget(s.splimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1,true)
			end
		end
	end
end

function s.GetOriginalVibe(c)
	---1 = Negative; +0 = Neutral; +1 = Positive
	local batk,bdef
	if c:HasAttack() then
		batk=c:GetBaseAttack()
	end
	if c:HasDefense() then
		bdef=c:GetBaseDefense()
	end
	
	if not batk or not bdef then return end
	local stat=batk-bdef
	if stat==0 then
		return stat
	else
		return stat/math.abs(stat)
	end
end