--Aircaster Gale
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_TRIGGER_O,0)
	aux.AddAircasterEquipEffect(c,1)
	--At the start of the Damage Step, if the equipped monster battles a monster: Discard 1 random card from your opponent's hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetFunctions(s.econ,nil,s.target,s.operation)
	c:RegisterEffect(e1)
end
function s.econ(e)
	if not e:GetHandler():IsSpell(TYPE_EQUIP) then return false end
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	local bc=ec:GetBattleTarget()
	return bc
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g<=0 then return end
	local tc=g:RandomSelect(p,1):GetFirst()
	if tc:IsDiscardable(REASON_EFFECT) then
		Duel.SendtoGrave(tc,REASON_DISCARD|REASON_EFFECT)
	else
		Duel.ConfirmCards(1-p,tc)
	end
end