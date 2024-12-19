--[[
Vacuous Archfiend - Zero Sum Slash
Arcidemone Vacuo - Fendente Somma Zero
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	aux.AddMaterialCodeList(c,CARD_VACUOUS_MONARCH)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterEqualFunction(Card.GetBaseAttack,0),aux.FilterBoolFunction(Card.IsCode,CARD_VACUOUS_MONARCH),1,1)
	--[[If this card is Synchro Summoned: You can pay 3000 LP; banish as many cards your opponent controls, face-down, up to the number of your opponent's banished cards (or all of their cards, if
	less than that number).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.SynchroSummonedCond,
		aux.PayLPCost(3000),
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e1)
	--[[Up to thrice per turn: You can return 1 banished card to the GY; destroy 1 card your opponent controls, then if that card was a monster, your opponent loses LP equal to its original ATK or DEF
	(whichever is higher, or its ATK if tied). This is a Quick Effect if you control "Power Vacuum Zone".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetFunctions(
		nil,
		s.descost,
		s.destg,
		s.desop
	)
	c:RegisterEffect(e2)
	local e2q=e2:QuickEffectClone(c,aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1))
	e2:SetLabelObject(e2q)
	e2q:SetLabelObject(e2)
	--[[While this card is equipped with "Power Vacuum Blade", it can attack on all monsters your opponent controls during each Battle Phase, once each.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
--E1
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
	local ct=Duel.GetBanishmentCount(1-tp)
	if chk==0 then
		return ct>0 and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,math.min(ct,#g),0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
	local ct=Duel.GetBanishmentCount(1-tp)
	if ct==0 or #g==0 then return end
	if #g>ct then
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		g=g:Select(tp,ct,ct,nil)
		Duel.HintSelection(g)
	end
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end

--E2
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToReturnToGraveAsCost,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToReturnToGraveAsCost,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.HintSelection(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	e:GetLabelObject():UseCountLimit(tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if Duel.Highlight(g) and Duel.Destroy(g,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		if tc:IsMonster() then
			local val=math.max(tc:GetTextAttack(),tc:GetTextDefense())
			if val>0 then
				Duel.LoseLP(1-tp,val)
			end
		end
	end
end

--E3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),1,nil)
end