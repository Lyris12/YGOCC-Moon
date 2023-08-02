--Trappit Trap Hole
--Buco Trappolaniglio
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id=GetID()
function s.initial_effect(c)
	--[[If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step): Add 1 "Trappit" monster from your Deck to your hand, also you can apply 1 of these effects.
	● Immediately after this effect resolves, Normal Summon/Set 1 monster.
	● Flip Summon 1 monster.
	● Send from your Deck to the GY, 1 Normal Trap that activates when a monster(s) is Normal or Flip Summoned, or Normal Set, except "Trappit Trap Hole", and that meets its activation conditions, and if you do, apply its effect when that card is activated.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_SUMMON|CATEGORY_POSITION|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(6)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.acthandcon)
	c:RegisterEffect(e3)
end
function s.acthandcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,nil)
end

--Filters E1
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToHand()
end
function s.actfilter(c)
	if not c:IsNormalTrap() or not c:IsAbleToGrave() or c:IsCode(id) or c:CheckActivateEffect(false,true,true)==nil then return false end
	local egroup=c:GetEffects()
	local res=false
	for i,e in ipairs(egroup) do
		if e and not e:WasReset(c) then
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
				local event=e:GetCode()
				if (event==EVENT_SUMMON_SUCCESS or event==EVENT_FLIP_SUMMON_SUCCESS) or e:IsHasCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET) then
					res=true
					break
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
	
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local shuffle=false
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 then
			shuffle=true
		end
	end
	if not e:GetHandler():AskPlayer(tp,2) then return end
	if shuffle then
		Duel.ShuffleHand(tp)
	end
	local b1=Duel.IsExistingMatchingCard(Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,nil,tp,true)
	local b3=Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil)
	local opt=aux.Option(tp,id,3,b1,b2,b3)
	if opt==0 then
		local g=Duel.Select(HINTMSG_SUMMON,false,tp,Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.SummonOrSet(tp,tc)
		end
		
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_POSITION,false,tp,Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
		local tc=g:GetFirst()
		if tc then
			Duel.FlipSummon(tp,tc)
		end
		
	elseif opt==2 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		Duel.RegisterHint(tp,id,PHASE_END,1,id,7)
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
			if not te then return end
			local tg=te:GetTarget()
			local op=te:GetOperation()
			Duel.SetProxyEffect(e,te)
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			Duel.ResetProxyEffect()
			Duel.BreakEffect()
			tc:CreateEffectRelation(te)
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				for etc in aux.Next(g) do
					etc:CreateEffectRelation(te)
				end
			end
			Duel.SetProxyEffect(e,te)
			if op then op(e,tp,ceg,cep,cev,cre,cr,crp) end
			Duel.ResetProxyEffect()
			tc:ReleaseEffectRelation(te)
			if g then
				for etc in aux.Next(g) do
					etc:ReleaseEffectRelation(te)
				end
			end
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end