--[[
Pentacle Quintet of Greed
Pentacolo del Quintetto della Cupidigia
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BLADE)
	--You can only control 1 "Pentacle Quintet of Greed".
	c:SetUniqueOnField(1,0,id)
	--[[When this card is activated: Both players shuffle their entire hand into the Deck (if possible), then draw 5 cards.]]
	local e0=c:Activation(true,true,nil,nil,s.target,s.activate,true)
	e0:SetDescription(id,0)
	e0:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	c:RegisterEffect(e0)
	--[[Once per turn: You can discard any number of "Sceluspecter" monsters; draw that same number of cards.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DummyCost,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e2)
	--[[If you would detach exactly 1, 2, or 3 materials from a DARK Xyz Monster(s) you control for that monster's effect, you can choose not to detach materials.
	The effect(s) requiring you to detach materials still resolve.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.rcon)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
end
--E1
function s.tdfilter(c,tp)
	if not Duel.IsPlayerCanSendtoDeck(tp,c) then return false end
	if not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) then return true end
	local eset={c:IsHasEffect(EFFECT_CANNOT_TO_DECK)}
	for _,e in ipairs(eset) do
		if e:GetOwner()~=c then
			return false
		end
	end
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local h1,h2=Duel.Group(s.tdfilter,tp,LOCATION_HAND,0,nil,tp):GetCount(),Duel.Group(s.tdfilter,1-tp,LOCATION_HAND,0,nil,1-tp):GetCount()
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsLocation(LOCATION_HAND) then
			h1=h1-1
		end
		return (Duel.IsPlayerCanDraw(tp,5) or h1==0) and (Duel.IsPlayerCanDraw(1-tp) or h2==0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,PLAYER_ALL,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local h1,h2=Duel.Group(s.tdfilter,tp,LOCATION_HAND,0,nil,tp),Duel.Group(s.tdfilter,1-tp,LOCATION_HAND,0,nil,1-tp)
	if #h1+#h2==0 then return end
	if Duel.ShuffleIntoDeck(h1+h2) then
		Duel.BreakEffect()
		Duel.Draw(tp,5,REASON_EFFECT)
		Duel.Draw(1-tp,5,REASON_EFFECT)
	end
end

--E2
function s.dcfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsDiscardable()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hand=Duel.Group(s.dcfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return e:IsCostChecked() and #hand>0 and Duel.IsPlayerCanDraw(tp,1) end
	local max=0
	for i=math.min(Duel.GetDeckCount(tp),#hand),1,-1 do
		if Duel.IsPlayerCanDraw(tp,i) then
			max=i
			break
		end
	end
	if max==0 then return end
	local ct=Duel.DiscardHand(tp,s.dcfilter,1,max,REASON_COST|REASON_DISCARD,nil)
	Duel.SetTargetParam(ct)
	Duel.SetTargetPlayer(tp)
	aux.DrawInfo(tp,ct)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--E3
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_COST~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and ev>0 and ev<=3
		and re:GetHandler():IsAttribute(ATTRIBUTE_DARK) and re:GetHandler():IsControler(tp)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	return ev
end