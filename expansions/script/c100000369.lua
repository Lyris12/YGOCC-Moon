--[[
Vacuous Shadow
Ombra Vacua
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_VACUOUS_VASSAL)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterEqualFunction(Card.GetBaseAttack,0),aux.NonTuner(nil),1)
	--[[If this card is Synchro Summoned: You can return as many of your banished "Vacuous Vassal" to the GY as possible, and if you do, and you returned a monster(s) to the GY this way, you can
	Special Summon as many Level 5 "Vacuous" monsters as possible from your hand, Deck, GY or banishment, up to the number of those returned monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		s.rttg,
		s.rtop
	)
	c:RegisterEffect(e1)
	--[[Up to twice per turn: You can banish 1 "Vacuous Vassal" from your hand or GY; banish 1 card your opponent controls, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetFunctions(
		nil,
		aux.BanishCost(aux.FilterBoolFunction(Card.IsCode,CARD_VACUOUS_VASSAL),LOCATION_HAND|LOCATION_GRAVE,0,1),
		xgl.SendtoTarget(LOCATION_REMOVED,nil,aux.TRUE,0,LOCATION_ONFIELD,1,1,nil,POS_FACEDOWN),
		xgl.SendtoOperation(LOCATION_REMOVED,nil,aux.TRUE,0,LOCATION_ONFIELD,1,1,nil,POS_FACEDOWN)
	)
	c:RegisterEffect(e2)
	--[[Each time an attack is declared involving a monster you control and an opponent's monster, your opponent immediately loses 500 LP.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end

--E1
function s.rtfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(CARD_VACUOUS_VASSAL) and c:IsAbleToReturnToGrave(e,tp,REASON_EFFECT)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.rtfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.rtfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):Filter(Card.IsLocation,nil,LOCATION_GRAVE):FilterCount(Card.IsMonster,nil)
		local ft=Duel.GetMZoneCountForMultipleSummons(tp)
		local sg=Duel.Group(aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GB,0,nil,e,tp)
		if ct>0 and ft>0 and #sg>0 and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			local n=math.min(ft,#sg,ct)
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			sg=sg:Select(tp,n,n,nil)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--E3
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c1,c2=Duel.GetBattleMonsters()
	return c1 and c2
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
