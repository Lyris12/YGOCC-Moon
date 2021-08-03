--CODEMAN: Prototype Z3R0
local s,id=GetID()
function s.initial_effect(c)
	for _,code in ipairs({EFFECT_CANNOT_BE_FUSION_MATERIAL,EFFECT_CANNOT_BE_SYNCHRO_MATERIAL,EFFECT_CANNOT_BE_XYZ_MATERIAL,EFFECT_CANNOT_BE_LINK_MATERIAL,EFFECT_CANNOT_BE_ACCENTED_MATERIAL,EFFECT_CANNOT_BE_ANNOTEE_MATERIAL,EFFECT_CANNOT_BE_BIGBANG_MATERIAL,EFFECT_CANNOT_BE_BYPATH_MATERIAL,EFFECT_CANNOT_BE_EVOLUTE_MATERIAL,EFFECT_CANNOT_BE_HARMONIZED_MATERIAL,EFFECT_CANNOT_BE_IMPURE_MATERIAL,EFFECT_CANNOT_BE_MAGICK_MATERIAL,EFFECT_CANNOT_BE_PERDITION_MATERIAL,EFFECT_CANNOT_BE_POLARITY_MATERIAL,EFFECT_CANNOT_BE_SPACE_MATERIAL,EFFECT_CANNOT_BE_TIMELEAP_MATERIAL,EFFECT_CANNOT_BE_XROS_MATERIAL})	do
		--material limit
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(code)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e0:SetValue(function(e) return e:GetHandler():IsLocation(LOCATION_MZONE) end)
		c:RegisterEffect(e0)
	end
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62968263,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22423493,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--remove (experimental)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.adjcon)
	e3:SetOperation(s.adjop)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return #g>=2 and g:IsExists(aux.NOT(Card.IsAttack),1,nil,Card.GetBaseAttack)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.disfilter1,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingTarget(aux.disfilter1,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	Duel.SelectTarget(tp,aux.disfilter1,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	Duel.SelectTarget(tp,aux.disfilter1,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g~=2 then return end
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
function s.adjfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ded)
end
function s.adjcon(e,tp)
	return not Duel.IsExistingMatchingCard(s.adjfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.adjop(e)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
