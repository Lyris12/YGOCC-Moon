--[[
Power Vacuum Zone
Zona Potere Vacuum
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_VACUOUS_VASSAL,CARD_POWER_VACUUM_BLADE)
	--[[When this card is activated: You can add 2 cards from your Deck to your hand (1 "Vacuous" monster and 1 Spell/Trap that mentions "Power Vacuum Zone"), and if you do, send 1 "Vacuous Vassal"
	from your hand or Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[Neither player takes any battle or effect damage, also monsters with 0 original ATK/DEF you control cannot be destroyed by battle.]]
	c:CannotBeDestroyedByBattleField(1,LOCATION_FZONE,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsBaseStats,0,0))
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(s.damval)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3x)
	--[[While you control "Power Vacuum Blade" equipped to a "Vacuous" Synchro Monster you control, the ATK/DEF of all monsters on the field become 0.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(s.atcon)
	e4:SetValue(0)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e5)
end
--E1
function s.thfilter1(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS) and c:IsAbleToHand()
		and Duel.IsExists(false,s.thfilter2,tp,LOCATION_DECK,0,1,c,c,tp)
end
function s.thfilter2(c,c1,tp)
	return c:IsST() and c:Mentions(CARD_POWER_VACUUM_ZONE) and c:IsAbleToHand()
		and Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,Group.FromCards(c,c1))
end
function s.tgfilter(c)
	return c:IsCode(CARD_VACUOUS_VASSAL) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExists(false,s.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g1==0 then return end
		local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,g1,g1:GetFirst(),tp)
		g1:Merge(g2)
		if #g1==2 and Duel.SearchAndCheck(g1,nil,nil,nil,nil,#g1) then
			local g3=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil)
			if #g3>0 then
				Duel.SendtoGrave(g3,REASON_EFFECT)
			end
		end
	end
end

--E3
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end

--E4
function s.eqfilter(c,tp)
	if not (c:IsFaceup() and c:IsCode(CARD_POWER_VACUUM_BLADE)) then return end
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(tp) and ec:IsType(TYPE_SYNCHRO) and ec:IsSetCard(ARCHE_VACUOUS)
end
function s.atcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExists(false,s.eqfilter,tp,LOCATION_SZONE,0,1,nil,tp)
end