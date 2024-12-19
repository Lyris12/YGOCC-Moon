--[[
ZERO-XII-XV
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_BLADE,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_ARCHFIEND,CARD_VACUOUS_MONARCH,CARD_VACUOUS_VASSAL)
	--[[If you control "Power Vacuum Zone", you can activate this card from your hand.]]
	c:TrapCanBeActivatedFromHand(aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1),aux.Stringid(id,0))
	--[[Tribute 1 "Vacuous Vassal" and 1 Level 5 "Vacuous" monster from your hand and/or field; Special Summon, from your hand, Deck, GY, or banishment, 1 "Vacuous Monarch", and if you do, equip 1
	"Power Vacuum Blade" from your hand, Deck, GY, or banishment to it. You cannot Summon other monsters during the turn you activate this effect, except monsters whose original ATK/DEF is 0.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_EQUIP|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		aux.SSRestrictionCost(aux.FilterBoolFunction(Card.IsTextStats,0,0),true,nil,id,nil,2,
			true,
			aux.TributeGlitchyCost(aux.TRUE,2,2,nil,true,false,nil,nil,nil,nil,nil,nil,nil,s.gcheck)
		),
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card, "Vacuous Monarch", and "Vacuous Vassal" are in your GY: You can target 1 "Vacuous Monarch" and 1 "Vacuous Vassal" in your GY; banish this card and those targets, and if you do,
	Special Summon 1 "Vacuous Archfiend" from your Extra Deck, ignoring its Summoning conditions (this is treated as a Synchro Summon), and if you do, immediately after this effect resolves, equip 1
	"Power Vacuum Blade" to it from your hand, Deck, GY, or banishment.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_EQUIP|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end
--E1
function s.pairfilter(c1,c2)
	return c1:IsCode(CARD_VACUOUS_VASSAL) and c2:IsLevel(5) and c2:IsSetCard(ARCHE_VACUOUS)
end
function s.gcheck(g,e,tp,mg,c)
	if #g==1 then return true end
	local ftcheck=Duel.GetMZoneCount(tp,g)>0
	if not ftcheck then
		return false, true
	end
	local c1,c2=g:GetFirst(),g:GetNext()
	return s.pairfilter(c1,c2) or s.pairfilter(c2,c1)
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_VACUOUS_MONARCH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,c,tp,c)
end
function s.eqfilter(c,tp,ec)
	return c:IsFaceupEx() and c:IsCode(CARD_POWER_VACUUM_BLADE) and s.eqcheck(c,ec,tp)
end
function s.eqcheck(c,ec,tp)
	if c:IsType(TYPE_EQUIP) then
		return c:IsAppropriateEquipSpell(ec,tp)
	else
		return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ft=(not c:IsLocation(LOCATION_SZONE) and e:IsHasType(EFFECT_TYPE_ACTIVATE)) and 1 or 0
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsFaceup() then
		local ec=Duel.Select(HINTMSG_EQUIP,false,tp,aux.Necro(s.eqfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,1,nil,tp,tc):GetFirst()
		if ec then
			if ec:IsType(TYPE_EQUIP) then
				Duel.Equip(tp,ec,tc)
			else
				Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,tc)
			end
		end
	end
end

--E2
function s.rmfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e) and c:IsCode(CARD_VACUOUS_VASSAL,CARD_VACUOUS_MONARCH)
end
function s.pairfilter(c1,c2)
	return c1:IsCode(CARD_VACUOUS_VASSAL) and c2:IsCode(CARD_VACUOUS_MONARCH)
end
function s.rmcheck(g,e,tp,mg,c)
	if #g==1 then return true end
	local c1,c2=g:GetFirst(),g:GetNext()
	return (s.pairfilter(c1,c2) or s.pairfilter(c2,c1)) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,g,g,e,tp)
end
function s.spfilter2(c,g,e,tp)
	return c:IsCode(CARD_VACUOUS_ARCHFIEND) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,true,false)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,g,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,c,e)
	local sg=Duel.Group(s.spfilter2,tp,LOCATION_EXTRA,0,nil,nil,e,tp)
	if chk==0 then
		local ft=(not c:IsLocation(LOCATION_SZONE) and e:IsHasType(EFFECT_TYPE_ACTIVATE)) and 1 or 0
		return c:IsAbleToRemove() and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>ft and #sg>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rmcheck,0)
	end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rmcheck,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(rg)
	rg:AddCard(c)
	Duel.SetCardOperationInfo(rg,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsControler,nil,tp):Filter(Card.IsCode,nil,CARD_VACUOUS_VASSAL,CARD_VACUOUS_MONARCH)
	if c:IsRelateToChain() then
		g:AddCard(c)
	end
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then
		local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,nil,e,tp):GetFirst()
		if tc then
			tc:SetMaterial(nil)
			if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,true,false,POS_FACEUP)>0 and tc:IsFaceup() then
				tc:CompleteProcedure()
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
				aux.ApplyEffectImmediatelyAfterResolution(s.eqop(tc),c,e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
function s.eqop(tc)
	return	function(e,tp,eg,ep,ev,re,r,rp,_e,isChainEnd)
				if not tc:HasFlagEffect(id) then return end
				tc:ResetFlagEffect(id)
				local ec=Duel.Select(HINTMSG_EQUIP,false,tp,aux.Necro(s.eqfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,1,1,nil,tp,tc):GetFirst()
				if ec then
					if ec:IsType(TYPE_EQUIP) then
						Duel.Equip(tp,ec,tc)
					else
						Duel.EquipToOtherCardAndRegisterLimit(e,tp,ec,tc)
					end
				end
			end
end