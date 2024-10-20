--[[
Invernal of the Meteor Hammer
Invernale del Martello Meteora
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[At the end of a Battle Phase in which an "Invernal" monster or a DARK Xyz Monster you controlled destroyed an opponent's Special Summoned monster by battle:
	You can reveal this card in your hand; Special Summon this card, and if you do, destroy all Spells/Traps your opponent controls (if any).
	Cards destroyed by this effect cannot activate their effects during that same turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		aux.RevealSelfCost(),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can Set 1 "Invernal" Spell/Trap from your Deck or GY. It can be activated this turn.]]
	local f=aux.ArchetypeFilter(ARCHE_INVERNAL)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		xgl.SSetTarget(false,f,LOCATION_DECK|LOCATION_GRAVE,1,nil),
		xgl.SSetOperation(Duel.SSetAndFastActivation,false,f,LOCATION_DECK|LOCATION_GRAVE,1,1,nil)
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card attached to it as material gains this effect.
	● At the start of the Damage Step, if this card battles a monster with a higher ATK (Quick Effect): This card gains ATK equal to the difference between this card's and that monster's ATK,
	during damage calculation only.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.xmatcon)
	e3:SetTarget(s.xmattg)
	e3:SetOperation(s.xmatop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsFaceup() and (tc:IsSetCard(ARCHE_INVERNAL) or (tc:IsType(TYPE_XYZ) and tc:IsSetCard(ARCHE_NUMBER) and tc:IsAttribute(ATTRIBUTE_DARK))) then
			local p=tc:GetControler()
			local bc=tc:GetBattleTarget()
			if bc and bc:IsControler(1-p) and bc:IsSpecialSummoned() then
				Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_BATTLE,0,1)
			end
		end
	end
end

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	local g=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_ONFIELD)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			local og=Duel.GetGroupOperatedByThisEffect(e)
			for tc in aux.Next(og) do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_CANNOT_TRIGGER)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or not bc then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and bc:IsFaceup() and bc:IsAttackAbove(c:GetAttack()+1)
end
function s.xmattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	Duel.SetTargetCard(bc)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,math.abs(bc:GetAttack()-c:GetAttack()))
end	
function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToChain() and bc:IsRelateToBattle() and c:IsRelateToBattle() then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetLabelObject(bc)
		e4:SetCondition(s.atkcon)
		e4:SetValue(s.atkval)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_DAMAGE_CAL)
		c:RegisterEffect(e4)
	end
end

--E4
function s.atkcon(e)
	local bc=e:GetLabelObject()
	if not bc or not bc:IsRelateToBattle() then
		e:Reset()
		return false
	end
	return bc:IsFaceup()
end
function s.atkval(e,c)
	local bc=e:GetLabelObject()
	return math.abs(bc:GetAttack()-e:GetHandler():GetAttack())
end