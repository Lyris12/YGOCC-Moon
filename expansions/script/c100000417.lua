--[[
Remnant Re-Overlay
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Target 1 "Number" Xyz Monster you control; reveal "Number" Xyz Monsters from your Extra Deck, whose numbers are lower than the number of that target, up to the number of cards your opponent currently controls, and attach them to that target as materials, and if you do, that target gains 300 ATK/DEF for each material attached to it this way until the end of the next turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If you Xyz Summon a "Number C" Xyz Monster(s) using a "Number" Xyz Monster you control with 1 or more "Number" Xyz Monsters attached to it as materials while this card is in your GY (except during the Damage Step): You can banish this card from your GY; Special Summon 1 "Number" Xyz Monster from your Extra Deck, ignoring its Summoning conditions, and if you do, attach 2 cards your opponent controls to it as materials. (This is treated as an Xyz Summon.)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SHOPT()
	e1:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e1:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.cfilter),
		aux.bfgcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
end

--E1
function s.filter1(c,e,tp)
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_NUMBER) and no
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no)
end
function s.filter2(c,e,tp,mc,no)
	local cno=aux.GetXyzNumber(c)
	return c:IsType(TYPE_XYZ) and cno and cno<no and c:IsSetCard(ARCHE_NUMBER) and c:IsCanBeAttachedTo(mc,e,tp,REASON_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,tp,0,300,OPINFO_FLAG_HIGHER)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local no=aux.GetXyzNumber(tc)
	if tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not tc:IsSetCard(ARCHE_NUMBER) or not no then return end
	local max=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,max,nil,e,tp,tc,no)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		local ct=Duel.Attach(g,tc,false,e,REASON_EFFECT,tp)
		if ct>0 and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsControler(tp) and tc:IsSetCard(ARCHE_NUMBER) then
			tc:UpdateATKDEF(ct*300,nil,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
		end
	end
end

--E2
function s.cfilter(c,_,tp)
	if not (c:IsXyzSummoned() and c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsSetCard(ARCHE_NUMBER_C)) then return false end
	local mg=c:GetMaterial()
	return mg:IsExists(s.matfilter,1,nil,tp,c:GetOverlayGroup())
end
function s.matfilter(c,tp,mg)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_NUMBER)
		and mg:FilterCount(s.ovfilter,c,c)>0
end
function s.ovfilter(c,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:GetPreviousXyzHolder()==mc
end
function s.tdfilter(c,xyzc,e,tp)
	return c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	if not (c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,true,false)) then
		return false
	end
	local g=Duel.Group(s.tdfilter,tp,0,LOCATION_ONFIELD,nil,c,e,tp)
	return #g>=2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
			and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	local c=e:GetHandler()
	local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		local g=Duel.Group(s.tdfilter,tp,0,LOCATION_ONFIELD,nil,sc,e,tp)
		if #g>=2 then
			Duel.HintMessage(tp,HINTMSG_ATTACH)
			local ag=g:Select(tp,2,2,sc)
			Duel.HintSelection(ag)
			Duel.Attach(ag,sc,false,e,REASON_EFFECT,tp)
		end
	end
end