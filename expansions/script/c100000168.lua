--[[
Monochrome Valkyrie RK4
Valchiria Monocroma RK4
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2)
	--[[If this card is Xyz Summoned: You can attach 1 Level 4 or lower Synchro Monster from the field or either GY to it as material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[You can detach 1 material from this card; draw cards equal to the number of Synchro Monsters on the field and that are attached to monsters on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,aux.DetachSelfCost(),s.drawtg,s.drawop)
	c:RegisterEffect(e2)
	--[[You can banish this card from your GY, then target up to 2 "Black and White Wave" in your GY; add them to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT()
	e3:SetFunctions(nil,aux.bfgcost,s.thtg,s.thop)
	c:RegisterEffect(e3)
end
--E1
function s.xyzfilter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(4) and c:IsCanOverlay(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,e:GetHandler(),tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.xyzfilter),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,c,tp)
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc and not tc:IsImmuneToEffect(e) then
			Duel.Attach(tc,c)
		end
	end
end

--E2
function s.drawfilter(c)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsType(TYPE_SYNCHRO)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.drawfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)+Duel.GetOverlayGroup(tp,1,1):FilterCount(s.drawfilter,nil)
	if chk==0 then
		if e:IsCostChecked() and c:GetOverlayGroup():IsExists(s.drawfilter,1,nil) then
			ct=ct-1
		end
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTargetPlayer()
	local ct=Duel.GetMatchingGroupCount(s.drawfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)+Duel.GetOverlayGroup(tp,1,1):FilterCount(s.drawfilter,nil)
	Duel.Draw(tp,ct,REASON_EFFECT)
end

--E3
function s.filter(c)
	return c:IsCode(CARD_BLACK_AND_WHITE_WAVE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		local exc
		if e:IsCostChecked() then exc=e:GetHandler() end
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,exc)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Search(g,tp)
	end
end