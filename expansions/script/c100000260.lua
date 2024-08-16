--[[
Sceluspecter Possession Phantom
Scelleraspettro Spirito della Possessione
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
	--[[If this card is banished: You can return 1 of your other banished cards to the GY; draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		s.drawcost,
		s.drawtg,
		s.drawop
	)
	c:RegisterEffect(e2)
	--[[While this card is equipped to a monster, the owner of this card takes control of the equipped monster, also, that monster becomes a DARK Fiend monster, and its ATK becomes 2000]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetValue(s.ctval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_ATTACK)
	e4:SetValue(2000)
	c:RegisterEffect(e4)
end

--E2
function s.cfilter(c,e)
	return c:IsAbleToReturnToGraveAsCost(e)
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,c,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_REMOVED,0,1,1,c,e)
	Duel.HintSelection(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--E3
function s.ctval(e,c)
	return e:GetHandler():GetOwner()
end