--[[
Nullfinite Overlay
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, or when your opponent Special Summons an Xyz Monster (in which case this is a Quick Effect), while this card is banished (except during the Damage Step): You can
	Special Summon 1 DARK Fiend Xyz Monster from your Extra Deck (this is treated as an Xyz Summon), and if you do, attach 3 of your face-up banished monsters to it as material, including this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCustomCategory(CATEGORY_ATTACH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetLabelObject(aux.AddThisCardBanishedAlreadyCheck(c))
	e1a:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	c:RegisterEffect(e1a)
	--[[If this card is banished, except from the Deck: You can target 1 of your face-down banished cards; return it to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(s.thcon,nil,s.rttg,s.rtop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(1-tp)
end
function s.tdfilter(c,xyzc,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.spfilter(c,e,tp,h)
	if not (c:IsType(TYPE_XYZ) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)) then
		return false
	end
	if not h then return true end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil,c,e,tp)
	return #g>=3 and g:IsContains(h)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
			and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,3,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	local c=e:GetHandler()
	local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		if not c:IsRelateToChain() then return end
		local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil,sc,e,tp)
		if #g>=3 and g:IsContains(c) then
			Duel.HintMessage(tp,HINTMSG_ATTACH)
			local ag=g:Select(tp,2,2,c)+c
			Duel.Attach(ag,sc,false,e,REASON_EFFECT,tp)
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
function s.rtfilter(c,e,tp)
	return c:IsFacedown() and c:IsAbleToReturnToGrave(e,tp)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.rtfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rtfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.rtfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_RETURN)
	end
end