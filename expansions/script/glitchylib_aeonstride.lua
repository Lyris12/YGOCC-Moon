----AEONSTRIDE LIBRARY
FLAG_AEONSTRIDE_TURN_MOVE 					= 100000100
STRING_ASK_AEONSTRIDE_TRIGGER_EFFECT		= aux.Stringid(100000100,0)
STRING_INPUT_MOVE_TURN_COUNT				= aux.Stringid(100000100,1)

EVENT_TURN_COUNT_MOVED						= 100000101

--Custom Turn Count
Auxiliary.TurnCountModifier = 0
local _GetTurnCount = Duel.GetTurnCount

Duel.GetTurnCount = function(...)
	local x={...}
	local p=#x>0 and x[1] or nil
	local custom=#x>1 and x[2] or nil
	if custom then
		if p then
			return _GetTurnCount(p)+aux.TurnCountModifier
		else
			return _GetTurnCount()+aux.TurnCountModifier
		end
	else
		if p then
			return _GetTurnCount(...)
		else
			return _GetTurnCount()
		end
	end
end

function Duel.IsPlayerCanMoveTurnCount(ct,e,tp,r)
	return ct>=0 or Duel.GetTurnCount(nil,true)>math.abs(ct)
end

function Duel.MoveTurnCountCustom(ct,e,tp,r)
	local turnct0=Duel.GetTurnCount(nil,true)
	Auxiliary.TurnCountModifier = Auxiliary.TurnCountModifier + ct
	local turnct1=Duel.GetTurnCount(nil,true)
	
	if aux.GlitchyHelper and turnct1<=20 and turnct1>0 then
		aux.GlitchyHelper:SetTurnCounter(turnct1)
	else
		Duel.Hint(HINT_CARD,tp,TOKEN_GLITCHY_HELPER)
		Duel.AnnounceNumber(tp,turnct1)
	end
	
	local diff=turnct1-turnct0
	if diff~=0 then
		Duel.RaiseEvent(e:GetHandler(),EVENT_TURN_COUNT_MOVED,e,r,tp,tp,diff)
	end
	
	return diff
end

--Manage Turn Count Modification Event when players pass turns
function Auxiliary.RegisterTurnCountTriggerEffectFlag(c,e)
	local prop=EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE
	if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(prop)
	e3:SetCode(FLAG_AEONSTRIDE_TURN_MOVE)
	e3:SetLabelObject(e)
	e3:SetLabel(c:GetOriginalCode())
	c:RegisterEffect(e3)
end

function Auxiliary.RaiseAeonstrideEndOfTurnEvent(c)--,desc,ctg,prop,cond,cost,tg,op)
	-- local e=Effect.CreateEffect(c)
	-- e:Desc(desc)
	-- if ctg then
		-- e:SetCategory(ctg)
	-- end
	-- if prop then
		-- e:SetProperty(prop)
	-- end
	-- e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	-- e:SetCode(EVENT_CUSTOM+FLAG_AEONSTRIDE_TURN_MOVE)
	-- e:SetRange(LOCATION_MZONE)
	-- e:HOPT()
	-- if cond then
		-- e:SetCondition(cond)
	-- end
	-- if cost then
		-- e:SetCost(cost)
	-- end
	-- if tg then
		-- e:SetTarget(tg)
	-- end
	-- if op then
		-- e:SetOperation(op)
	-- end
	-- c:RegisterEffect(e)
	-- aux.RegisterTurnCountTriggerEffectFlag(c,e)
	--
	if not aux.EventTurnEndTrigger then
		aux.EventTurnEndTrigger=true
		local ge0=Effect.CreateEffect(c)
		ge0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge0:SetCode(EVENT_TURN_END)
		ge0:OPT()
		ge0:SetOperation(aux.StartTurnCountTriggerEffects)
		Duel.RegisterEffect(ge0,0)
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START|PHASE_DRAW)
		ge1:OPT()
		ge1:SetOperation(aux.ActivateTurnCountTriggerEffects)
		Duel.RegisterEffect(ge1,0)
		ge0:SetLabelObject(ge1)
	end
end

Auxiliary.ConvertChainToEffectRelation=false
Auxiliary.TurnCountMovedDueToTurnEnd=false
function Auxiliary.StartTurnCountTriggerEffects(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1,0,0)
	e:Reset()
end
function Auxiliary.ActivateTurnCountTriggerEffects(e,tp,eg,ep,ev,re,r,rp)
	aux.ConvertChainToEffectRelation=true
	local l1,actp,passed_priority=e:GetLabel()
	if l1~=1 then return end
	
	if e:GetCode()~=EVENT_CHAINING then
		aux.TurnCountMovedDueToTurnEnd = true
		local turnct1=Duel.GetTurnCount(nil,true)
		if aux.GlitchyHelper and turnct1<=20 and turnct1>0 then
			aux.GlitchyHelper:SetTurnCounter(turnct1)
		else
			Duel.Hint(HINT_CARD,tp,TOKEN_GLITCHY_HELPER)
			Duel.AnnounceNumber(tp,turnct1)
		end
		
		Duel.RaiseEvent(Group.CreateGroup(),EVENT_TURN_COUNT_MOVED,nil,REASON_RULE,PLAYER_NONE,PLAYER_NONE,1)
	end
	
	local turnp=e:GetCode()~=EVENT_CHAINING and Duel.GetTurnPlayer() or actp-2
	local activated_effects={}
	for p=turnp,1-turnp,1-2*turnp do
		if passed_priority&(p+1)==0 then 
			local g1=Duel.Group(aux.HasTurnCountTriggerEffect,p,LOCATION_ONFIELD|LOCATION_EXTRA|LOCATION_GB,0,nil,p)
			if #g1>0 then
				local ok=true
				if #g1>0 then
					if Duel.SelectYesNo(p,STRING_ASK_AEONSTRIDE_TRIGGER_EFFECT) then
						local tc=g1:Select(p,1,1,nil):GetFirst()
						if tc then
							local available_effects,descs={},{}
							local egroup=tc:GetEffects()
							for _,teh in ipairs(egroup) do
								if aux.GetValueType(teh)=="Effect" and teh:GetCode()==FLAG_AEONSTRIDE_TURN_MOVE then
									local te=teh:GetLabelObject()
									if tc:IsLocation(te:GetRange()) and te:IsActivatable(p) then
										table.insert(available_effects,te)
										table.insert(descs,te:GetDescription())
									end
								end
							end
							if #available_effects>0 then
								local opt=Duel.SelectOption(tp,table.unpack(descs))+1
								local ce=available_effects[opt]
								if aux.GetValueType(ce)=="Effect" then
									local ge1=Effect.CreateEffect(e:GetHandler())
									ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
									ge1:SetCode(EVENT_CHAINING)
									ge1:OPT()
									ge1:SetLabel(l1,p+2,passed_priority)
									ge1:SetOperation(aux.ActivateTurnCountTriggerEffects)
									Duel.RegisterEffect(ge1,0)
									Duel.Activate(ce)
									tc:CreateEffectRelation(ce)
									Duel.BreakEffect()
									break
								end
							end
						end
					end
					passed_priority=passed_priority|(p+1)
				end
			else
				passed_priority=passed_priority|(p+1)
			end
		end
	end
	if e:GetCode()==EVENT_CHAINING then
		e:Reset()
	else
		aux.TurnCountMovedDueToTurnEnd = false
		aux.ConvertChainToEffectRelation=false
	end
end
function Auxiliary.HasTurnCountTriggerEffect(c,tp)
	if not c:IsFaceup() then return false end
	local egroup=c:GetEffects()
	for _,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and teh:GetCode()==FLAG_AEONSTRIDE_TURN_MOVE then
			local te=teh:GetLabelObject()
			if c:IsLocation(te:GetRange()) and te:IsActivatable(tp) then
				return true
			end
		end
	end
	return false
end