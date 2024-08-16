--[[
Sceluspecter Vanishing Phantom
Scelleraspettro Spirito Evanescente
Card Author: Walrus
Scripted by: XGlitchy30
]]

if not GLITCHYLIB_YGOCC_ARCHETYPES_LOADED then
	Duel.LoadScript("glitchylib_ygocc_archetypes.lua")
end

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase, if this card is in your hand (Quick Effect): You can banish 1 "Sceluspecter" monster from your GY; equip this card to 1 monster your opponent controls.]]
	YGOCC.RegisterSceluspecterEquip(c,id)
	--[[If this card is banished: You can shuffle this card into the Deck; activate 1 "Sceluspecter Doomed Bastille" directly from your Deck or GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.ToDeckSelfCost,
		s.acttg,
		s.actop
	)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a monster, that monster becomes a DARK Fiend monster, also it is banished face-down when it leaves the field.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetCondition(function()
		return not s.PreventWrongRedirect
	end)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local ec=e:GetHandler():GetEquipTarget()
		return ec and not s.PreventWrongRedirect and eg:IsContains(ec)
	end)
	e4:SetOperation(s.bfdop)
	c:RegisterEffect(e4)
end

--E2
function s.filter(c,tp)
	return c:IsCode(CARD_SCELUSCEPTER_DOOMED_BASTILLE) and c:IsDirectlyActivatable(tp,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.ActivateDirectly(tc,tp)
	end
end

--E4
function s.bfdop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	s.PreventWrongRedirect=true
	Duel.Remove(ec,POS_FACEDOWN,ec:GetReason()|REASON_REDIRECT)
	s.PreventWrongRedirect=false
end