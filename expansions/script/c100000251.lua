--[[
Automatyrant Stasis Gears Dragon
Automatiranno Drago Stasi di Ingranaggi
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Machine Tuner + "Automatyrant Clockwork Dragon"
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.FilterBoolFunction(Card.IsCode,CARD_AUTOMATYRANT_CLOCKWORK_DRAGON),1,1)
	aux.AddMaterialCodeList(c,CARD_AUTOMATYRANT_CLOCKWORK_DRAGON)
	--[[If this card is Synchro Summoned: You can target 1 Equip Spell or Union monster from either GY; equip it to this card, and if you do, send the top 3 cards of both player's Decks to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_EQUIP|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.SynchroSummonedCond,nil,s.eqtg,s.eqop)
	c:RegisterEffect(e1)
	--[[When your opponent activates a card or effect (Quick Effect): You can Tribute 1 Equip Card you control; negate the activation, and if you do, destroy it.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		s.discon,
		aux.TributeGlitchyCost(nil,1,1,nil,false,false,Card.IsEquipCard,LOCATION_SZONE,0),
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
	--[[Each time an Equip Spell(s) or Union monster(s) is sent to the GY, immediately inflict 800 damage to your opponent for each.]]
	aux.RegisterMaxxCEffect(c,id,nil,LOCATION_MZONE,EVENT_TO_GRAVE,s.damcon,s.damopOUT,s.damopIN,s.flaglabel)
end
s.has_text_type=TYPE_UNION

--E1
function s.eqfilter(c,tc,tp)
	return c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
		and ((c:IsMonster(TYPE_UNION) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc))
		or (c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(tc)))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,c,tp,e) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(true,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,tp)
			and Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.IsPlayerCanDiscardDeck(1-tp,3)
	end
	local g=Duel.Select(HINTMSG_EQUIP,true,tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
	Duel.SetCardOperationInfo(g,CATEGORY_LEAVE_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,3)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not c:IsRelateToChain() or not c:IsFaceup() then return end
	if Duel.Equip(tp,tc,c) then
		for p in aux.TurnPlayers() do
			Duel.DiscardDeck(p,3,REASON_EFFECT)
		end
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return Duel.IsChainNegatable(ev) and rp==1-tp
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--E3
function s.tgcheck(c)
	return c:IsMonster(TYPE_UNION) or c:IsSpell(TYPE_EQUIP)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tgcheck,1,nil)
end
function s.flaglabel(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.tgcheck,nil)
end
function s.damopOUT(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct=eg:FilterCount(s.tgcheck,nil)
	Duel.Damage(1-tp,ct*800,REASON_EFFECT)
end
function s.damopIN(e,tp,eg,ep,ev,re,r,rp,n)
	Duel.Hint(HINT_CARD,tp,id)
	local labels={Duel.GetFlagEffectLabel(tp,id)}
	local ct=0
	for i=1,#labels do
		ct=ct+labels[i]
	end
	Duel.Damage(1-tp,ct*800,REASON_EFFECT)
end