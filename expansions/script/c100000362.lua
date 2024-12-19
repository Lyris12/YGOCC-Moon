--[[
Power Vacuum Blade
Lama di Potere Vacuum
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_VASSAL)
	--Activation
	aux.AddEquipSpellEffect(c,true,false,s.eqfilter,s.eqlim,false,false)
	--[[At the start of the Damage Step, if this card battles an opponent's monster, your opponent loses LP equal to that monster's original (if that monster's ATK/DEF is currently 0) or current (if
	not) ATK or DEF (whichever is higher, or its ATK if tied), then shuffle that monster into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	--[[Once per turn: You can banish 1 "Vacuous Vassal" from your hand or GY; double the ATK/DEF of all monsters your opponent controls. For the rest of this turn after this effect resolves, if your
	opponent would lose LP equal to or higher than their current LP, their LP becomes halved, instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_ATKDEF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetFunctions(
		nil,
		aux.BanishCost(aux.FilterBoolFunction(Card.IsCode,CARD_VACUOUS_VASSAL),LOCATION_HAND|LOCATION_GRAVE),
		s.atktg,
		s.atkop)
	Auxiliary.RegisterGrantEffect(c,LOCATION_SZONE,LOCATION_MZONE,LOCATION_MZONE,s.granttg,e1,e2)
	--[[Neither player takes damage from attacks involving this card, also if this card battles an opponent's monster, neither can be destroyed by that battle.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(s.indval)
	c:RegisterEffect(e5)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_EQUIP)
	e7:SetCode(EFFECT_ADD_TYPE)
	e7:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_EQUIP)
	e8:SetCode(EFFECT_REMOVE_TYPE)
	e8:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e8)
	--[[If this card is in your GY while you control "Power Vacuum Zone": You can target 1 "Vacuous" monster in your GY; add both it and this card to your hand.]]
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(id,3)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1),
		nil,
		s.thtg,
		s.thop)
	c:RegisterEffect(e6)
end
function s.eqfilter(c)
	if not c:IsFaceup() then return false end
	return c:IsBaseStats(0,0)
end
function s.eqlim(e,c)
	return c:IsBaseStats(0,0)
end
function s.granttg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end

--E1
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if not bc then return false end
	return bc:IsRelateToBattle() and bc:IsControler(1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(bc)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=0
	local bc=e:GetLabelObject()
	local battle_relation=bc:IsRelateToBattle()
	if battle_relation and bc:IsFaceup() and bc:IsControler(1-tp) then
		dam=bc:IsStats(0,0) and math.max(bc:GetBaseAttack(),bc:GetBaseDefense()) or bc:GetMaxStat()
	end
	if dam>0 then
		local oglp=Duel.GetLP(1-tp)
		Duel.Hint(HINT_CARD,tp,id)
		Duel.LoseLP(1-tp,dam)
		if Duel.GetLP(1-tp)<oglp and bc:IsRelateToBattle() and bc:IsAbleToDeck() then
			Duel.BreakEffect()
			Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--E2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,0,0,-2,OPINFO_FLAG_DOUBLE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:DoubleATK(true,{c,true})
		tc:DoubleDEF(true,{c,true})
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_MODIFY_LP_CHANGE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.lpval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.lpval(e,tp,val,r,rp,chk)
	if chk==0 then return val<=0 and r&LP_REASON_BECOME==0 end
	local lp=Duel.GetLP(tp)
	return math.floor(0.5 + lp/2)
end

--E5
function s.indval(e,c)
	local h=e:GetHandler():GetEquipTarget()
	local bc=h:GetBattleTarget()
	if not bc or not bc:IsControler(1-e:GetHandlerPlayer()) then return false end
	if c==h or c==bc then
		return 1
	else
		return 0
	end
end

--E6
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and c:IsAbleToHand() and tc:IsAbleToHand() then
		Duel.Search(Group.FromCards(c,tc))
	end
end