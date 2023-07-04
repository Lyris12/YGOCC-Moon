--Oscurion Type-0 ‹Cradle of the Universe›
--Oscurione Tipo-0 ‹Culla dell'Universo›
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,13)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[If you have 10 "Oscurion" monsters with different Levels in your GY, you win the Duel.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.winop)
	c:RegisterEffect(e1)
	--[[(Quick Effect): You can target 1 "Oscurion" Drive Monster in your GY; apply that target's Drive Effect that activates by discarding an "Oscurion" card,
	also, for the rest of this turn, you cannot target monsters with that same original name to activate this effect of "Oscurion Type-0 ‹Cradle of the Universe›".]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s.code_list={{},{}}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:SetCountLimit(1)
		ge1:SetOperation(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.code_list={{},{}}
end
function s.splimit(e,se,sp,st)
	if not (se:IsOverDriveEffect() and se:IsHasType(EFFECT_TYPE_ACTIONS)) then return false end
	local sc=se:GetHandler()
	return sc and se:IsActiveType(TYPE_DRIVE) and sc:IsSetCard(ARCHE_OSCURION)
end

--FILTERS E1
function s.winfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_OSCURION) and c:HasLevel()
end
--E1
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.winfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>=10 and g:GetClassCount(Card.GetLevel)>=10 then
		Duel.Win(tp,WIN_REASON_CUSTOM)
	end
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER)
end
function s.TLcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.TLmaterial(c)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_PSYCHIC)
end

--FILTERS E2
function s.filter(c,tp,tab,e)
	if #tab>0 then
		local codes={c:GetOriginalCodeRule()}
		if aux.FindInTable(tab,table.unpack(codes)) then
			return false
		end
	end
	if not (c:IsMonster(TYPE_DRIVE) and c:IsSetCard(ARCHE_OSCURION)) then return false end
	local egroup=c:GetEffects()
	for _,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_OSCURION_TYPE0 then
			local te=teh:GetLabelObject()
			if aux.GetValueType(te)=="Effect" then
				local tg=te:GetTarget()
				Duel.SetProxyEffect(e,te)
				if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
					Duel.ResetProxyEffect()
					return true
				end
				Duel.ResetProxyEffect()
			end
		end
	end
	return false
end
--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tab=s.code_list[tp+1]
	e:SetCostCheck(false)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp,tab,e) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp,tab,e) and not e:GetHandler():IsStatus(STATUS_CHAINING) and not Duel.PlayerHasFlagEffect(tp,id)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp,tab,e)
	local tc=g:GetFirst()
	if tc then
		local codes={tc:GetOriginalCodeRule()}
		e:SetLabel(table.unpack(codes))
		local egroup=tc:GetEffects()
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(egroup) do
			if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_OSCURION_TYPE0 then
				local temp=teh:GetLabelObject()
				if aux.GetValueType(temp)=="Effect" then
					local tg=temp:GetTarget()
					Duel.SetProxyEffect(e,temp)
					if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
						table.insert(ac,teh)
						table.insert(acd,temp:GetDescription())
					end
					Duel.ResetProxyEffect()
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
			Duel.SetProxyEffect(e,te)
			tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
			Duel.ResetProxyEffect()
		end
		e:SetOperation(s.operation(te,teh))
	end
end
function s.operation(te,teh)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if aux.GetValueType(te)~="Effect" then return end
				e,tp,eg,ep,ev,re,r,rp = aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				e:SetCostCheck(false)
				local codes={e:GetLabel()}
				for _,code in ipairs(codes) do
					table.insert(s.code_list[tp+1],code)
				end
				local tc=e:GetLabelObject()
				if tc:IsRelateToEffect(e) and tc:IsMonster(TYPE_DRIVE) and tc:IsSetCard(ARCHE_OSCURION) and tc:IsControler(tp) then
					Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,nil)
					tc:CreateEffectRelation(e)
					Duel.BreakEffect()
					local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(e)
					end
					local op=te:GetOperation()
					if op then
						Duel.SetProxyEffect(e,te)
						op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
						Duel.ResetProxyEffect()
					end
					tc:ReleaseEffectRelation(e)
					for etc in aux.Next(g) do
						etc:ReleaseEffectRelation(e)
					end
				end
			end
end