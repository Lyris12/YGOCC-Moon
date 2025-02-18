--[[
Vacuous Vassal
Vassallo Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	--[[If this card is Normal or Special Summoned: You can add 1 "Vacuous" monster from your Deck or GY to your hand, except "Vacuous Vassal", and if you do, immediately after this effect resolves,
	Special Summon 1 Level 5 "Vacuous" monster from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can Tribute this card; activate 1 "Power Vacuum Zone" directly from your hand, Deck, or GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCustomCategory(CATEGORY_ACTIVATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:HOPT()
	e2:SetFunctions(aux.MainPhaseCond(),aux.TributeSelfCost,s.acttg,s.actop)
	c:RegisterEffect(e2)
	--[[During the End Phase, if this card was banished this turn, and is banished face-up: You can show 1 "Power Vacuum Blade" from your Deck or GY; return this card to the GY, and if you do, either
	add that card to your hand, or equip it to 1 "Vacuous" monster you control.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORIES_SEARCH|CATEGORY_EQUIP|CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:OPT()
	e3:SetFunctions(s.cond,nil,s.targ,s.op)
	c:RegisterEffect(e3)
end
--E1
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(5) and c:IsSetCard(ARCHE_VACUOUS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
			and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g) and Duel.GetMZoneCount(tp)>0 then
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.ShuffleHand(tp)
			local tc=sg:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_HAND)
			e1:SetCondition(s.spcon)
			e1:SetValue(id)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			aux.RegisterResetAfterSpecialSummonRule(tc,tp,e1)
			Duel.SpecialSummonRule(tp,tc,id)
			if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
		end
	end
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetMZoneCount(tp)>0
end

--E2
function s.actfilter(c,tp)
	return c:IsCode(CARD_POWER_VACUUM_ZONE) and c:IsDirectlyActivatable(tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.actfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.Select(HINTMSG_TOFIELD,false,tp,aux.Necro(s.actfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.ActivateDirectly(tc,tp)
	end
end

--E3
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end
function s.eqtofilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VACUOUS)
end
function s.eqcheck(c,ec,tp)
	if ec:IsType(TYPE_EQUIP) then
		return ec:IsAppropriateEquipSpell(c,tp)
	else
		return not ec:IsForbidden() and ec:CheckUniqueOnField(tp,LOCATION_SZONE)
	end
end
function s.filter(c,tp,ftchk,g)
	if not c:IsCode(CARD_POWER_VACUUM_BLADE) then return false end
	return c:IsAbleToHand() or (ftchk and g:IsExists(s.eqcheck,1,nil,c,tp))
end
function s.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ftchk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local g=Duel.Group(s.eqtofilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return c:IsAbleToReturnToGrave(e,tp,REASON_EFFECT) and Duel.IsExists(false,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,ftchk,g)
	end
	local tc=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp,ftchk,g):GetFirst()
	Duel.SetTargetCard(tc)
	if tc:IsInGY() then
		Duel.HintSelection(Group.FromCards(tc))
	else
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleDeck(tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,tc,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SendtoGraveAndCheck(c,nil,REASON_EFFECT|REASON_RETURN) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and aux.NecroValleyFilter(tc) then
			local ftchk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			local g=Duel.Group(s.eqtofilter,tp,LOCATION_MZONE,0,nil)
			local b1=tc:IsAbleToHand()
			local b2=ftchk and g:IsExists(s.eqcheck,1,nil,tc,tp)
			if not b1 and not b2 then return end
			local opt=aux.Option(tp,nil,nil,{b1,STRING_ADD_TO_HAND},{b2,STRING_EQUIP})
			if opt==0 then
				Duel.Search(tc)
			elseif opt==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local eqg=g:FilterSelect(tp,s.eqcheck,1,1,nil,tc,tp)
				local eqc=eqg:GetFirst()
				Duel.HintSelection(eqg)
				if tc:IsType(TYPE_EQUIP) then
					Duel.Equip(tp,tc,eqc)
				else
					Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,eqc)
				end
			end	
		end
	end
end