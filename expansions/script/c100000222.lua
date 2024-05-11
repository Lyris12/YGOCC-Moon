--[[
Might of Verdanse
Forza di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--[[If you control a "Verdanse" Ritual or Xyz Monster: Destroy all face-up cards your opponent controls, then apply the following effects,
	in sequence, depending on the "Verdanse" monster card types in your Monster Zones (skip over any that do not apply).
	● Ritual: Inflict 800 damage to your opponent for each card destroyed by this effect.
	● Xyz: Roll a six-sided die, then banish as many cards from your opponent's GY as possible, face-down, up to the result.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE|CATEGORY_DICE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		aux.LocationGroupCond(aux.FilterBoolFunction(s.cfilter,TYPE_RITUAL|TYPE_XYZ),LOCATION_MZONE,0,1),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[During your Standby Phase, if this card is in your GY: You can target 1 other "Verdanse" card in your GY, except "Might of Verdanse";
	shuffle both it and this card into the Deck, and if you do, draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.StandbyPhaseCond(0),
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
end
s.toss_dice=true

--E1
function s.cfilter(c,typ)
	return c:IsFaceup() and c:IsMonster(typ) and c:IsSetCard(ARCHE_VERDANSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(Card.IsFaceup,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_ONFIELD)
	local ritchk=Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_RITUAL)
	local xyzchk=Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ)
	Duel.SetConditionalOperationInfo(ritchk,0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	Duel.SetConditionalOperationInfo(xyzchk,0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetConditionalOperationInfo(xyzchk,0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(Card.IsFaceup,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local brk=false
		local ct=Duel.GetOperatedGroup():FilterCount(aux.BecauseOfThisEffect(e),nil)
		if ct>0 and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_RITUAL) then
			Duel.BreakEffect()
			if Duel.Damage(1-tp,ct*800,REASON_EFFECT)>0 then
				brk=true
			end
		end
		if Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) then
			local dc=Duel.TossDice(tp,1)
			local g=Duel.Group(aux.Necro(Card.IsAbleToRemoveFacedown),tp,0,LOCATION_GRAVE,nil,tp)
			if #g==0 then return end
			local ct=math.min(#g,dc)
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg=g:Select(tp,ct,ct,nil)
			if #rg>0 then
				Duel.HintSelection(rg)
				if brk then
					Duel.BreakEffect()
				end
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.tdfilter(c)
	return c:IsSetCard(ARCHE_VERDANSE) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) and Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Group.FromCards(c,g:GetFirst()),2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and Duel.ShuffleIntoDeck(Group.FromCards(c,tc))==2 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end