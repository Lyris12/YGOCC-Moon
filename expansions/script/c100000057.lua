--[[
Deep, Deep in the Dreary Forest's Maze
Nel Profondo del Labirinto della Foresta Tetra
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your opponent's turn: Target 1 monster your opponent controls with less ATK than the highest ATK or DEF (whichever is higher) among "Dreamy Forest" and "Dreary Forest" monsters you control; equip it to a "Dreamy Forest" or "Dreary Forest" monster you control as an Equip Spell with the following effects.
	● If this card is equipped to a "Dreamy Forest" monster, your opponent cannot activate cards, or the effects of cards, with the same name as this card during your turn.
	● If this card is equipped to a "Dreary Forest" monster, your opponent cannot activate cards, or the effects of cards, with the same name as this card during their turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(aux.TurnPlayerCond(1),nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.maxstat(c)
	if c:HasAttack() and c:HasDefense() then
		return math.max(c:GetAttack(),c:GetDefense())
	elseif c:HasAttack() then
		return c:GetAttack()
	else
		return c:GetDefense()
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST)
end
function s.filter(c,tp,max)
	return c:IsFaceup() and c:IsAttackBelow(max) and c:IsAbleToChangeControler() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
		and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local _,max=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil):GetMaxGroup(s.maxstat)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and s.filter(chkc,tp,max-1)
	end
	if chk==0 then
		local c=e:GetHandler()
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return ft>0 and max and Duel.IsExists(true,s.filter,tp,0,LOCATION_MZONE,1,nil,tp,max-1)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp,max-1)
	Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and not tc:IsForbidden() and tc:CheckUniqueOnField(tp,LOCATION_SZONE) and tc:IsAbleToChangeControler()
	and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 then
		local g=Duel.Select(HINTMSG_EQUIP,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,tc)
		if #g>0 then
			Duel.HintSelection(g)
			if Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,g:GetFirst()) then
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
				local c=e:GetHandler()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetRange(LOCATION_SZONE)
				e1:SetTargetRange(0,1)
				e1:SetCondition(s.eqcon(ARCHE_DREAMY_FOREST,0))
				e1:SetValue(s.aclimit)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCondition(s.eqcon(ARCHE_DREARY_FOREST,1))
				tc:RegisterEffect(e2,true)
			end
		end
	end
end
function s.eqcon(set,turnp)
	return	function(e)
				local p=turnp==0 and e:GetHandlerPlayer() or 1-e:GetHandlerPlayer()
				local eq=e:GetHandler():GetEquipTarget()
				return eq and eq:IsSetCard(set) and Duel.GetTurnPlayer()==p
			end
end
function s.aclimit(e,re,tp)
	local c=e:GetHandler()
	return re:GetHandler():IsCode(c:GetCode())
end