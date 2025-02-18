--[[
Vacuous Mirrored Vassal
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_VASSAL)
	--This card's name becomes "Vacuous Vassal" while in the hand, Deck, GY, banishment, or on the field.
	aux.EnableChangeCode(c,CARD_VACUOUS_VASSAL,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	--[[If this card is Normal or Special Summoned: You can send 2 "Vacuous" monsters from your hand and/or Deck to the GY, except "Vacuous Mirrored Vassal", and if you do, immediately after this
	effect resolves, Set 1 Trap Card directly from your hand, Deck, or GY that mentions "Power Vacuum Zone". It can be activated this turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.tgtg,
		s.tgop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[During the Main Phase (Quick Effect): You can Tribute this card; Special Summon 3 "Vacuous Unform Tokens" (LIGHT/Fiend/Level 1/ATK 0/DEF 0) to your field in Attack Position. They cannot be
	used as Link Materials.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		aux.MainPhaseCond(),
		aux.TributeSelfCost,
		s.tktg,
		s.tkop
	)
	c:RegisterEffect(e2)
	--[[During the End Phase, if this card was banished this turn, and is banished face-up: You can show 1 Level 5 or lower monster in your Deck or GY with 0 ATK/DEF; return this card to the GY, and
	if you do, either add that showed card to your hand or Special Summon it in Defense Position.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:HOPT()
	e3:SetFunctions(s.cond,nil,s.targ,s.op)
	c:RegisterEffect(e3)
end
--E1
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and not c:IsOriginalCodeRule(id) and c:IsAbleToGrave()
end
function s.setfilter(c)
	return c:IsTrap() and c:Mentions(CARD_POWER_VACUUM_ZONE) and c:IsSSetable()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,nil)
			and Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,2,nil)
	if #g==2 and Duel.SendtoGraveAndCheck(g,nil,nil,2) then
		aux.ApplyEffectImmediatelyAfterResolution(s.setop,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp,_e,isChainEnd)
	local tc=Duel.Select(HINTMSG_SET,false,tp,aux.Necro(s.setfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSetAndFastActivation(tp,tc,e)
	end
end

--E2
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local exc=e:IsCostChecked() and c or nil
		return Duel.GetMZoneCount(tp,exc)>=3 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,ARCHE_VACUOUS,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetMZoneCount(tp)<3
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,ARCHE_VACUOUS,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK) then
		return
	end
	local c=e:GetHandler()
	for i=1,3 do
		local token=Duel.CreateToken(tp,id+1)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end

--E3
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end
function s.filter(c,e,tp,ftchk)
	if not (c:IsMonster() and c:IsLevelBelow(5) and c:IsStats(0,0)) then return false end
	return c:IsAbleToHand() or (ftchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
function s.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ftchk=Duel.GetMZoneCount(tp)>0
	if chk==0 then
		return c:IsAbleToReturnToGrave(e,tp,REASON_EFFECT) and Duel.IsExists(false,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,ftchk)
	end
	local tc=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,ftchk):GetFirst()
	Duel.SetTargetCard(tc)
	if tc:IsInGY() then
		Duel.HintSelection(Group.FromCards(tc))
	else
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleDeck(tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SendtoGraveAndCheck(c,nil,REASON_EFFECT|REASON_RETURN) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and aux.NecroValleyFilter(tc) then
			local ftchk=Duel.GetMZoneCount(tp)>0
			local b1=tc:IsAbleToHand()
			local b2=ftchk and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			if not b1 and not b2 then return end
			local opt=aux.Option(tp,nil,nil,{b1,STRING_ADD_TO_HAND},{b2,STRING_SPECIAL_SUMMON})
			if opt==0 then
				Duel.Search(tc)
			elseif opt==1 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end	
		end
	end
end