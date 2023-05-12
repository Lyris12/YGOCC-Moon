--Roi du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--[[During your Main Phase: You can send up to 2 other "Vaisseau" Pendulum Monster Cards from your hand, field or face-up Extra Deck to the GY, then apply these effects in sequence, depending on the number of cards sent to the GY by this effect.
	● 1+: Add 1 "Rêverie du Vaisseau" from your Deck or GY to your hand.
	● 2: Destroy 1 Spell/Trap your opponent control.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
	--[[If this card was Ritual Summoned, you can activate this effect during your turn as well.
	Once per opponent's turn (Quick Effect): You can target 1 "Vaisseau" Pendulum Monster Card in your Pendulum Zone; this effect becomes that monster's original activated Pendulum Effect.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:OPT()
	e2:SetCondition(aux.VaisseauQECondition)
	e2:SetTarget(s.qetg)
	c:RegisterEffect(e2)
end
function s.tgfilter(c)
	return c:IsFaceupEx() and c:GetOriginalType()&(TYPE_MONSTER|TYPE_PENDULUM)==TYPE_MONSTER|TYPE_PENDULUM and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsCode(CARD_REVERIE_DU_VAISSEAU) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_EXTRA,0,nil)
	if chk==0 then
		return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetCardOperationInfo(g,CATEGORY_TOGRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_EXTRA,0,nil)
	if #g<=0 then return end
	local max=1
	if #g>=2 and Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil) then
		max=2
	end
	local rg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_EXTRA,0,1,max,nil)
	if #rg>0 then
		Duel.HintSelection(rg)
		if Duel.SendtoGrave(rg,REASON_EFFECT)>0 then
			local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE|LOCATION_EXTRA):FilterCount(Card.IsFaceupEx,nil)
			if ct>=1 then
				local ng=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
				if #ng>0 then
					Duel.BreakEffect()
					Duel.Search(ng,tp)
				end
			end
			if ct==2 then
				local dg=Duel.Select(HINTMSG_DESTROY,false,tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
				if #dg>0 then
					Duel.HintSelection(dg)
					Duel.BreakEffect()
					Duel.Destroy(dg,REASON_EFFECT)
				end
			end
		end
	end
end

function s.filter(c,tp)
	if not (c:IsFaceup() and c:GetOriginalType()&(TYPE_MONSTER|TYPE_PENDULUM)==TYPE_MONSTER|TYPE_PENDULUM and c:IsSetCard(ARCHE_VAISSEAU)) then return false end
	local egroup=c:GetEffects()
	for _,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and teh:GetCode()==id then
			local te=teh:GetLabelObject()
			local tg=te:GetTarget()
			if (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				return true
			end
		end
	end
	return false
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_PZONE,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local egroup=tc:GetEffects()
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(egroup) do
			if aux.GetValueType(teh)=="Effect" and teh:GetCode()==id then
				local temp=teh:GetLabelObject()
				local tg=temp:GetTarget()
				if (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
					table.insert(ac,teh)
					table.insert(acd,temp:GetDescription())
				end
			end
		end
		if #ac==1 then
			te=ac[1]
		elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		e:SetLabelObject(tc)
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		if tg then
			tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
		end
		e:SetOperation(s.qeop(te,teh))
	end
end
function s.qeop(te,teh)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if aux.GetValueType(te)~="Effect" then return end
				e,tp,eg,ep,ev,re,r,rp = aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				local tc=e:GetLabelObject()
				if tc:IsRelateToChain() then
					tc:CreateEffectRelation(te)
					Duel.BreakEffect()
					local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(te)
					end
					local op=te:GetOperation()
					if op then
						op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
					end
					tc:ReleaseEffectRelation(te)
					for etc in aux.Next(g) do
						etc:ReleaseEffectRelation(te)
					end
				end
			end
end