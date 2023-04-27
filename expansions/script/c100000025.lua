--Zerost Beast Zerotl
--Bestia Zerost Zerotl
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_ZEROST),2,6,true)
	--This Fusion Summoned card gains ATK/DEF equal to the number of monsters used for its Fusion Summon x 500.
	c:UpdateATKDEF(s.statval,nil,nil,nil,nil,aux.FusionSummonedCond)
	--If this card is Fusion Summoned: Roll a six-sided die, then apply the result.
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(aux.FusionSummonedCond)
	e2:SetTarget(s.dicetg)
	e2:SetOperation(s.diceop)
	c:RegisterEffect(e2)
	--[[(Quick Effect): You can target 1 banished Level 6 "Zerost" monster, that was banished by you; apply its effect that activates when it is banished by the effect of a "Zerost" card,
	and shuffle it into your Deck, also, for the rest of this turn, you cannot target monsters with the same name as that monster to activate this effect.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,RELEVANT_TIMINGS)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		
		s.code_list={{},{}}
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE|PHASE_END)
		ge2:SetCountLimit(1)
		ge2:SetCondition(s.resetop)
		Duel.RegisterEffect(ge2,0)
	end
end
s.toss_dice = true

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,tc:GetReasonPlayer())
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.code_list={{},{}}
	return false
end

function s.statval(e,c)
	local ct=e:GetHandler():GetMaterialCount()
	if not ct or ct<0 then ct=0 end
	return ct*500
end

function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	if c:IsRelateToChain() and c:IsFaceup() then
		local res=math.ceil(dc/2)
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT,1,res,aux.Stringid(id,res))
		e:GetLabelObject():SetCountLimit(res)
	end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
function s.filter(c,tp,tab)
	if #tab>0 then
		local codes={c:GetCode()}
		if aux.FindInTable(tab,table.unpack(codes)) then
			return false
		end
	end
	if not (c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_ZEROST) and c:IsLevel(6) and c:HasFlagEffectLabel(id+100,tp) and c:IsAbleToDeck()) then return false end
	local egroup=c:GetEffects()
	for _,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_ZEROST_BEAST_ZEROTL then
			local te=teh:GetLabelObject()
			local tg=te:GetTarget()
			if (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				return true
			end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tab=s.code_list[tp+1]
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.filter(chkc,tp,tab) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,tp,tab)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,tp,tab)
	local tc=g:GetFirst()
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	if tc then
		local codes={tc:GetCode()}
		e:SetLabel(table.unpack(codes))
		local egroup=tc:GetEffects()
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(egroup) do
			if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_ZEROST_BEAST_ZEROTL then
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
		e:SetOperation(s.operation(te,teh))
	end
end
function s.operation(te,teh)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if aux.GetValueType(te)~="Effect" then return end
				e,tp,eg,ep,ev,re,r,rp = aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				local codes={e:GetLabel()}
				for _,code in ipairs(codes) do
					table.insert(s.code_list[tp+1],code)
				end
				local tc=e:GetLabelObject()
				if tc:IsRelateToChain() and tc:IsAbleToDeck() then
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
					Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
end