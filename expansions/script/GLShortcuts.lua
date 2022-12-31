Glitchy=Glitchy or {}
local cm=Glitchy

-- USEFUL SHORTCUTS IN THE NANAHIRA FILE (id = 37564765)
-- These shortcuts will not be included here since already present in the c37564765.lua
--function cm.splimitcost(f,m,cost,...)
--function cm.splimit(c,v,rlimit)
--function cm.DescriptionCost(costf)
--function cm.ExileGroup(g)
--function cm.ExileCard(c)
--function cm.PreExile(c)
--function cm.NegateSummonModule(c,tpcode,ctlm,ctlmid,con,cost)
--function cm.NegateEffectModule(c,lmct,lmcd,cost,excon,exop,loc,force)
--function cm.NegateEffectTrap(c,lmct,lmcd,cost,excon,exop)
--function cm.DateCheck(dt,excon)


--Effect Givers
function cm.SingleEffectGiver(owner,receiver,code,reset,...)
	local extra_params={...}
	local val,label,label_obj,forced=extra_params[1],extra_params[2],extra_params[3],extra_params[4]
	if reset then res=reset else res=RESET_EVENT+RESETS_STANDARD end
	if res==1 then res=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END end
	local e1=Effect.CreateEffect(owner)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(code)
	if label then
		e1:SetLabel(label)
	end
	if label_obj then
		e1:SetLabelObject(label_obj)
	end
	if val then
		e1:SetValue(val)
	end
	e1:SetReset(res)
	if forced then
		receiver:RegisterEffect(e1,forced)
	else
		receiver:RegisterEffect(e1)
	end
	return e1
end

--Multiparam filters
function cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
	if not params then 
		params={} 
	else
		for pc=1,#params do
			if params[pc]=="e" then params[pc]=e
			elseif params[pc]=="tp" then params[pc]=tp
			elseif params[pc]=="eg" then params[pc]=eg
			elseif params[pc]=="ep" then params[pc]=ep
			elseif params[pc]=="ev" then params[pc]=ev
			elseif params[pc]=="re" then params[pc]=re
			elseif params[pc]=="r" then params[pc]=r
			elseif params[pc]=="rp" then params[pc]=rp
			elseif params[pc]=="chk" then params[pc]=chk
			end
		end
	end
end
function cm.PositionConverter(remtype)
	if remtype=="posUA" then return POS_FACEUP_ATTACK
	elseif remtype=="posUD" then return POS_FACEUP_DEFENSE
	elseif remtype=="posDA" then return POS_FACEDOWN_ATTACK
	elseif remtype=="posDD" then return POS_FACEDOWN_DEFENSE
	elseif remtype=="position" then return POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK
	elseif remtype=="flipup" then return POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE
	elseif remtype=="flipupsetavailable" then return POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,false,true
	else return POS_FACEUP_ATTACK end
end
function cm.FusionConverter(mat1,polytype,e,tp,eg,ep,ev,re,r,rp)
	if polytype=="standard" then Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	elseif polytype=="banish" then Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	elseif polytype=="banishfacedown" then Duel.Remove(mat1,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	elseif polytype=="bounce" then Duel.SendtoHand(mat1,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	elseif polytype=="spin" then Duel.SendtoDeck(mat1,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	elseif polytype=="destroy" then Duel.Destroy(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	else Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION) end
end
function cm.CategRemTypeConverter(remtype)
	if remtype=="destroy" then return CATEGORY_DESTROY
	elseif (remtype=="banish" or remtype=="banishfacedown") then return CATEGORY_REMOVE
	elseif remtype=="bounce" then return CATEGORY_TOHAND
	elseif remtype=="spin" then return CATEGORY_TODECK
	elseif remtype=="tograve" then return CATEGORY_TOGRAVE
	elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then return CATEGORY_POSITION
	end
end
--
function cm.MultipleTargetsCheck(c,e,tcheck,tp)
	return c:IsRelateToEffect(e) and (not tcheck or tcheck(c,e,tp))
end
function cm.MultipleTargetsCheckSet(c,e,tcheck,tp)
	return c:IsRelateToEffect(e) and c:IsSSetable() and (not tcheck or tcheck(c,e,tp))
end
function cm.ShuffleCheck(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
--COSTS AND CONDITIONS
function cm.SelfDiscardCost(...)
	local funs={...}
	local addcon=funs[1]
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsDiscardable() and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
			end
end
function cm.SelfToGraveCost(...)
	local funs={...}
	local addcon=funs[1]
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsAbleToGraveAsCost() and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				Duel.SendtoGrave(c,REASON_COST)
			end
end
function cm.SelfTributeCost(...)
	local funs={...}
	local addcon=funs[1]
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsReleasable() and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				Duel.Release(e:GetHandler(),REASON_COST)
			end
end
function cm.SelfBanishCost(...)
	local funs={...}
	local pos,addcon=funs[1],funs[2]
	if not pos then pos=POS_FACEUP end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return c:IsAbleToRemoveAsCost() and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				Duel.Remove(c,pos,REASON_COST)
			end
end
function cm.SelfDetachCost(remtotal,...)
	local funs={...}
	local remtotmax,addcon=funs[1],funs[2]
	if not remtotmax then remtotmax=remtotal end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,remtotal,REASON_COST) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				e:GetHandler():RemoveOverlayCard(tp,remtotal,remtotmax,REASON_COST)
			end
end
function cm.DiscardCost(minc,...)
	local funs={...}
	local maxc,filter,addcon,labelobj=funs[1],funs[2],funs[3],funs[4]
	if not maxc then maxc=minc end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if filter then
					local ffilter,fparams
					if type(filter(1))=="table" then
						ffilter,fparams=filter(0),filter(1)
						cm.ParamConverter(fparams,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						ffilter=filter
						fparams={}
					end
				end
				if chk==0 then return Duel.IsExistingMatchingCard(cm.IsDiscardable(ffilter,table.unpack(fparams)),tp,LOCATION_HAND,0,minc,e:GetHandler()) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
				Duel.DiscardHand(tp,cm.IsDiscardable(ffilter,table.unpack(fparams)),minc,maxc,REASON_COST+REASON_DISCARD)
			end
end
function cm.CheckFieldCountCond(ct,loc,p,...)
	local funs={...}
	local mode,addcon=funs[1],funs[2]
	if not mode then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local player
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					return Duel.GetFieldGroupCount(player,loc,0)==ct and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="<" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local player
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					return Duel.GetFieldGroupCount(player,loc,0)<ct and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="<=" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local player
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					return Duel.GetFieldGroupCount(player,loc,0)<=ct and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local player
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					return Duel.GetFieldGroupCount(player,loc,0)>ct and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">=" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local player
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					return Duel.GetFieldGroupCount(player,loc,0)>=ct and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	end
end
function cm.CompareFieldCond(...)
	local funs={...}
	local mode,addcon,loc1,loc2=funs[1],funs[2],funs[3],funs[4]
	if not loc1 then loc1=LOCATION_MZONE end
	if not loc2 then loc2=loc1 end
	if not mode then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),loc1,0,nil)<Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),loc1,0,nil)>Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="=" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),loc1,0,nil)==Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">=" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),loc1,0,nil)>=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="<=" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),loc1,0,nil)<=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	end
end
function cm.CheckPhaseCond(phase,...)
	local funs={...}
	local addcon=funs[1]
	if phase=="main" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local ph=Duel.GetCurrentPhase()
					return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local ph=Duel.GetCurrentPhase()
					return ph==phase and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	end
end
function cm.CheckTurnPlayerCond(p,...)
	local funs={...}
	local addcon=funs[1]
	local player
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
				return Duel.GetTurnPlayer()==player and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
			end
end
function cm.CheckPhaseAndTurnPlayerCond(phase,p,...)
	local funs={...}
	local addcon=funs[1]
	local player
	if phase=="main" then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					local ph=Duel.GetCurrentPhase()
					return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetTurnPlayer()==player  and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if p==0 then player=e:GetHandlerPlayer() else player=1-e:GetHandlerPlayer() end
					local ph=Duel.GetCurrentPhase()
					return ph==phase and Duel.GetTurnPlayer()==player and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	end
end
function cm.PayLPCost(amount,...)
	local funs={...}
	local divide,addcon=funs[1],funs[2]
	if not divide then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.CheckLPCost(tp,amount) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
					Duel.PayLPCost(tp,amount)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) end
					Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/divide))
				end
	end
end
function cm.SummonTypeCond(typ,...)
	local funs={...}
	local addcon=funs[1]
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return e:GetHandler():IsSummonType(typ) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
			end
end
function cm.ControlCond(remfilter,loc,ct,...)
	local funs={...}
	local addcon=funs[1]
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local filter,params
				if type(remfilter(1))=="table" then
					filter,params=remfilter(0),remfilter(1)
					cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp)
				else
					filter=remfilter
					params={}
				end
				return Duel.IsExistingMatchingCard(filter,tp,loc,0,ct,nil,table.unpack(params)) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
			end
end
--SPSUMMON PROC CONDITIONS
function cm.CompareFieldProcCond(...)
	local funs={...}
	local mode,addcon,loc1,loc2=funs[1],funs[2],funs[3],funs[4]
	if not loc1 then loc1=LOCATION_MZONE end
	if not loc2 then loc2=loc1 end
	if not mode then
		return	function(e,c)
					if c==nil then return true end
					return Duel.GetLocationCount(c:GetControler(),loc1)>0
						and Duel.GetFieldGroupCount(c:GetControler(),loc1,0,nil)<Duel.GetFieldGroupCount(c:GetControler(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">" then
		return	function(e,c)
					if c==nil then return true end
					return Duel.GetLocationCount(c:GetControler(),loc1)>0
						and Duel.GetFieldGroupCount(c:GetControler(),loc1,0,nil)>Duel.GetFieldGroupCount(c:GetControler(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="=" then
		return	function(e,c)
					if c==nil then return true end
					return Duel.GetLocationCount(c:GetControler(),loc1)>0
						and Duel.GetFieldGroupCount(c:GetControler(),loc1,0,nil)==Duel.GetFieldGroupCount(c:GetControler(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode==">=" then
		return	function(e,c)
					if c==nil then return true end
					return Duel.GetLocationCount(c:GetControler(),loc1)>0
						and Duel.GetFieldGroupCount(c:GetControler(),loc1,0,nil)>=Duel.GetFieldGroupCount(c:GetControler(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	elseif mode=="<=" then
		return	function(e,c)
					if c==nil then return true end
					return Duel.GetLocationCount(c:GetControler(),loc1)>0
						and Duel.GetFieldGroupCount(c:GetControler(),loc1,0,nil)<=Duel.GetFieldGroupCount(c:GetControler(),0,loc2,nil) and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp))
				end
	end
end
--FILTERS and TARGETCHECKS
function cm.Filter(faceup,arche,typ,attr,race,func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not faceup or c:IsFaceup()) and (not arche or c:IsSetCard(arche)) and (not typ or c:IsType(typ)) and (not attr or c:IsAttribute(attr))
					and (not race or c:IsRace(race)) and (not func or func(c,table.unpack(extra_params)))
			end
end
function cm.IsDiscardable(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsDiscardable()
			end
end
function cm.IsAbleToHand(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsAbleToHand()
			end
end
function cm.IsAbleToGrave(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsAbleToGrave()
			end
end
function cm.IsAbleToRemove(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsAbleToRemove()
			end
end
function cm.IsAbleToDeck(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsAbleToDeck()
			end
end
function cm.IsAbleToSet(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsSSetable()
			end
end
function cm.SPSummonOnceFilter(func,...)
	local extra_params={...}
	return	function(c,tp)
				return (not func or not func(c,table.unpack(extra_params))) and c:GetSummonPlayer()==tp
			end
end
function cm.DisableFilter(func,...)
	local extra_params={...}
	return	function (c)
				if type(c)=="number" then return 0 end
				return (not func or func(c,table.unpack(extra_params))) and c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
			end
end
function cm.TrapHoleTargetCheck(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return ep==tp and eg:GetFirst():IsFaceup() and eg:GetFirst():IsLocation(LOCATION_MZONE) and eg:GetFirst():IsCanBeEffectTarget(e) 
					and (not f or f(e,tp,eg,ep,ev,re,r,rp))
			end
end
function cm.TrapHoleMultipleTargetCheck(f,remfilter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return eg:IsExists(remfilter,1,nil,e,tp,eg,ep,ev,re,r,rp)
					and (not f or f(e,tp,eg,ep,ev,re,r,rp))
			end
end
function cm.SingleXyzLevelFilter(lv,fval)
	return	function (e,c,rc)
				if not fval or fval(rc,e) then
					return lv
				else
					return e:GetHandler():GetLevel()
				end
			end
end
---------
--CONJUNCTED EFFECTS
function cm.AcidTrapHoleConj(f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=Duel.GetOperatedGroup():GetFirst()
				if f(tc,e,tp,eg,ep,ev,re,r,rp) then
					Duel.BreakEffect()
					Duel.Destroy(tc,REASON_EFFECT)
				else
					Duel.ConfirmCards(1-tc:GetControler(),tc)
					Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
				end
			end
end
function cm.EffectGiverRelateConj(...)
	local extra_params={...}
	local mode,addcon,conjword,conjunct,also=extra_params[1],extra_params[2],extra_params[3],extra_params[4],extra_params[5]
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c,x=e:GetHandler(),Duel.GetOperatedGroup():GetFirst()
				if mode and mode==1 then c,x=x,c end
				if c:IsFaceup() and (not addcon or addcon(e,tp,eg,ep,ev,re,r,rp)) then
					if conjword and ((conjword=="andifyoudo" and conj) or (conjword=="then")) then
						conjunct(e,tp,eg,ep,ev,re,r,rp,c,x)
					end
				end
				if also then
					also(e,tp,eg,ep,ev,re,r,rp)
				end
			end
end
--------------------
--GLOBAL Check
function cm.GlobalStartup(id)
	local m=_G["c"..id]
	if not m then return false end
	local check=m.global_check
	if check==nil then
		check=true
	end
end
function cm.GlobalCountdownForTurn(c,id,...)
	local extra_params={...}
	local ct=extra_params[1]
	if not ct then ct=1 end
	local m=_G["c"..id]
	if not m then return false end
	m[0]=ct
	m[1]=ct
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
						m[0]=ct
						m[1]=ct
					end)
	Duel.RegisterEffect(ge1,0)
	return ge1
end
--ALSO CONJUNCTIONS
function cm.SPSummonOnceAlso(id,...)
--Requires GlobalCounterForTurn to be applied
	local extra_params={...}
	local funs,excfuns,also=extra_params[1],extra_params[2],extra_params[3]
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetTargetRange(1,0)
				e1:SetTarget(function (e,c,sump,sumtype,sumpos,targetp,se)
								local m=_G["c"..id]
								if not m then return false end
								return (not funs or funs(e,c,sump,sumtype,sumpos,targetp,se)) and (not excfuns or not excfuns(c,e,sump,sumtype,sumpos,targetp,se)) and m[sump]<=0
							 end)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e2:SetCode(EVENT_SPSUMMON_SUCCESS)
				e2:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
									local m=_G["c"..id]
									if not m then return false end
									if eg:IsExists(cm.SPSummonOnceFilter(excfuns),1,nil,tp) then
										m[tp]=m[tp]-1
									end
									if eg:IsExists(cm.SPSummonOnceFilter(excfuns),1,nil,1-tp) then
										m[1-tp]=m[1-tp]-1
									end
								end)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetCode(92345028)
				e3:SetTargetRange(1,0)
				e3:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e3,tp)
				if also then
					also(e,tp,eg,ep,ev,re,r,rp)
				end
			end
end
-------------------

--Single Effect Module
--[1]:Categories / [2]: Properties / [3]: Condition / [4]: Cost / [5]:Value / [6]: Enable HOPT Activation / [7]:Enable OATH
function cm.SingleEffectModule(c,etype,evef,actrange,target,operation,...)
	local funs={...}
	local etyp=0
	if etype~=0 and type(etype)=="string" then
		if etype=="continuous" then etyp=EFFECT_TYPE_CONTINUOUS
		elseif etype=="forced flip" then etyp=EFFECT_TYPE_FLIP
		elseif etype=="optional flip" then etyp=EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O
		elseif etype=="optional trigger" then etyp=EFFECT_TYPE_TRIGGER_O
		elseif etype=="forced trigger" then etyp=EFFECT_TYPE_TRIGGER_F
		else etyp=0
		end
	end
	local oath=0
	if funs[7] then
		oath=funs[7]
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+etyp)
	if evef then
		e1:SetCode(evef)
	end
	if actrange then
		e1:SetRange(actrange)
	end
	if funs[1] then
		e1:SetCategory(funs[1])
	end
	if funs[2] then
		e1:SetProperty(funs[2])
	end
	if funs[6] then
		if oath~=0 then
			e1:SetCountLimit(funs[6],oath)
		else
			e1:SetCountLimit(funs[6])
		end
	end
	if funs[3] then
		e1:SetCondition(funs[3])
	end
	if funs[4] then
		e1:SetCost(funs[4])
	end
	if target then
		e1:SetTarget(target)
	end
	if operation then
		e1:SetOperation(operation)
	end
	if funs[5] then
		e1:SetValue(funs[5])
	end
	return e1
end
--Field State Effect Shortcut
-- funs[1]: Properties, Condition
function cm.FieldStatusEffectModule(c,effect,actrange,selfrange,opporange,target,...)
	local funs={...}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(effect)
	e1:SetRange(actrange)
	e1:SetTargetRange(selfrange,opporange)
	if target then
		e1:SetTarget(target)
	end
	if funs[1] then
		e1:SetProperty(funs[1])
	end
	if funs[2] then
		e1:SetCondition(funs[2])
	end
	return e1
end
--Equip Effect Module
--funs[1]: Condition
function cm.EquipEffectModule(c,effect,...)
	local funs={...}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(effect)
	if funs[1] then
		e1:SetCondition(funs[1])
	end
	return e1
end
--Standard Activation Module
--[1]:Categories / [2]: Properties / [3]: Range / [4]: Condition / [5]:Cost / [6]: Enable HOPT Activation / [7]:Enable OATH
function cm.ActivateModule(c,event,typ,target,operation,...)
	local funs={...}
	local oath=0
	local tpe,range=EFFECT_TYPE_ACTIVATE,nil
	if typ then
		tpe=typ
		if funs[3] then
			range=funs[3]
		end
	end
	if funs[7] then
		oath=funs[7]
	end
	local e1=Effect.CreateEffect(c)
	if funs[1] then
		e1:SetCategory(funs[1])
	end
	if funs[2] then
		e1:SetProperty(funs[2])
	end
	e1:SetType(tpe)
	if range and typ~=EFFECT_TYPE_ACTIVATE then e1:SetRange(range) end
	if not event then
		e1:SetCode(EVENT_FREE_CHAIN)
	else
		e1:SetCode(event)
	end
	if funs[6] then
		if oath~=0 then
			e1:SetCountLimit(funs[6],oath)
		else
			e1:SetCountLimit(funs[6])
		end
	end
	if funs[4] then
		e1:SetCondition(funs[4])
	end
	if funs[5] then
		e1:SetCost(funs[5])
	end
	if target then
		e1:SetTarget(target)
	end
	if operation then
		e1:SetOperation(operation)
	end
	c:RegisterEffect(e1)
	return e1
end
--MATERIAL MODULE
function cm.MaterialModule(c,operation,...)
	local funs={...}
	local oath=0
	local tpe,range=EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS,nil
	if funs[7] then
		oath=funs[7]
	end
	local e1=Effect.CreateEffect(c)
	if funs[1] then
		e1:SetCategory(funs[1])
	end
	if funs[2] then
		e1:SetProperty(funs[2])
	end
	e1:SetType(tpe)
	e1:SetCode(EVENT_BE_MATERIAL)
	if funs[6] then
		if oath~=0 then
			e1:SetCountLimit(funs[6],oath)
		else
			e1:SetCountLimit(funs[6])
		end
	end
	if funs[4] then
		e1:SetCondition(funs[4])
	end
	if funs[5] then
		e1:SetCost(funs[5])
	end
	if operation then
		e1:SetOperation(operation)
	end
	c:RegisterEffect(e1)
	return e1
end

--STANDARD EQUIP PROCEDURE: Shortcut for Equip Spells
--[1]:Categories / [2]: Properties / [3]: Condition / [4]:Cost / [5]: Enable HOPT Activation / [6]:Enable OATH
function cm.EquipProcedure(c,target,selfloc,oppoloc,...)
	local funs={...}
	local prop,catg=0,0
	if funs[2] then
		prop=funs[2]
	end
	if funs[1] then
		catg=funs[1]
	end
	local oath=0
	if funs[6] then
		oath=funs[6]
	end
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+catg)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+prop)
	if funs[5] then
		if oath~=0 then
			e1:SetCountLimit(funs[5],oath)
		else
			e1:SetCountLimit(funs[5])
		end
	end
	if funs[3] then
		e1:SetCondition(funs[3])
	end
	if funs[4] then
		e1:SetCost(funs[4])
	end
	e1:SetTarget(cm.EquipTarget(cm.EQFilterConvert(target),selfloc,oppoloc))
	e1:SetOperation(cm.EquipOperation())
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(cm.EquipLimit(target))
	c:RegisterEffect(e2)
	return e1,e2
end
function cm.EQFilterConvert(filter)
	return	function(c)
				return c:IsFaceup() and (filter==1 or filter(c))
			end
end			
function cm.EquipTarget(filter,selfloc,oppoloc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local szone,ozone=0,0
				if selfloc then
					szone=LOCATION_MZONE
				end
				if oppoloc then
					ozone=LOCATION_MZONE
				end
				if chkc then return chkc:IsLocation(LOCATION_MZONE) and filter(chkc) end
				if chk==0 then return Duel.IsExistingTarget(filter,tp,szone,ozone,1,nil) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				Duel.SelectTarget(tp,filter,tp,szone,ozone,1,1,nil)
				Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
			end
end
function cm.EquipOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local tc=Duel.GetFirstTarget()
				if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
					Duel.Equip(tp,e:GetHandler(),tc)
				end
			end
end
function cm.EquipLimit(filter)
	if filter==1 then
		return 1
	else
		return	function(e,c)
					return filter(c)
				end
	end
end

------------------------------Single Effects------------------------------
function cm.SingleKeepOnField(c,...)
	local funs={...}
	local cond,prop,range=funs[1],funs[2],funs[3]
	local e1=cm.SingleEffectModule(c,nil,EFFECT_REMAIN_FIELD,range,nil,nil,nil,prop,cond,nil,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.SingleCannotBeMaterial(c,val,...)
	local funs={...}
	local fval,cond,prop,range=funs[1],funs[2],funs[3],funs[4]
	local filterval
	if not fval then filterval=1 else filterval=aux.FilterToCannotValue(fval) end
	local eval=0
	local pro=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE
	if prop then
		pro=pro|prop
	end
	if (not val or val==TYPE_FUSION) then eval=EFFECT_CANNOT_BE_FUSION_MATERIAL
	elseif val==TYPE_SYNCHRO then eval=EFFECT_CANNOT_BE_SYNCHRO_MATERIAL
	elseif val==TYPE_XYZ then eval=EFFECT_CANNOT_BE_XYZ_MATERIAL
	elseif val==TYPE_LINK then eval=EFFECT_CANNOT_BE_LINK_MATERIAL
	end
	local e1=cm.SingleEffectModule(c,nil,eval,range,nil,nil,nil,pro,cond,nil,filterval,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.SingleXyzLevel(c,lv,...)
	local funs={...}
	local fval,cond,prop,range=funs[1],funs[2],funs[3],funs[4]
	local e1=cm.SingleEffectModule(c,nil,EFFECT_XYZ_LEVEL,range,nil,nil,nil,prop,cond,nil,cm.XyzLevelFilter(lv,fval),nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.SingleBattleDestroyProtection(c,...)
	local funs={...}
	local cond,prop,range=funs[1],funs[2],funs[3]
	local pro=0
	if prop then pro=prop|EFFECT_FLAG_SINGLE_RANGE else pro=EFFECT_FLAG_SINGLE_RANGE end
	local e1=cm.SingleEffectModule(c,nil,EFFECT_INDESTRUCTABLE_BATTLE,LOCATION_MZONE,nil,nil,nil,pro,cond,nil,1,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.SingleEffectDestroyProtection(c,oppo,...)
	local funs={...}
	local cond,prop,range=funs[1],funs[2],funs[3]
	local pro=0
	if prop then pro=prop|EFFECT_FLAG_SINGLE_RANGE else pro=EFFECT_FLAG_SINGLE_RANGE end
	local val=1
	if oppo then val=aux.indoval end
	local e1=cm.SingleEffectModule(c,nil,EFFECT_INDESTRUCTABLE_EFFECT,LOCATION_MZONE,nil,nil,nil,pro,cond,nil,val,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.SingleTargetProtection(c,oppo,...)
	local funs={...}
	local cond,prop,range=funs[1],funs[2],funs[3]
	local pro=0
	if prop then pro=prop|EFFECT_FLAG_SINGLE_RANGE else pro=EFFECT_FLAG_SINGLE_RANGE end
	local val=1
	if oppo then val=aux.tgoval end
	local e1=cm.SingleEffectModule(c,nil,EFFECT_CANNOT_BE_EFFECT_TARGET,LOCATION_MZONE,nil,nil,nil,pro,cond,nil,val,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
------------------------------Activate Effects------------------------------
function cm.Activate(c)
	local e1=cm.ActivateModule(c,nil,nil,nil,nil)
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateHOPT(c)
	local e1=cm.ActivateModule(c,nil,nil,nil,nil,nil,nil,nil,nil,1,id)
	c:RegisterEffect(e1)
	return e1
end
--CARD REMOVAL WHEN ACTIVATED: Remove (destroy,banish,bounce...) a card(s) from a specified location when activated
-- funs[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] : Properties, Categories, Condition, Cost, Enable Exception, Additional Target conds, Target specs, BaitDollConfirmation, Enable Hopt, Enable OATH, forced
-- [11],[12],[13] : "andifyoudo" or "then", conjuncted effect, "also" effect
function cm.ActivateRemoval(c,event,typ,range,remtype,istargeting,remloc1,remloc2,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	local cnew=cm.CategRemTypeConverter(remtype)
	if funs[2] then
		categ=funs[2]+cnew
	else
		categ=cnew
	end
	if istargeting then prop=prop+EFFECT_FLAG_CARD_TARGET end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.RemovalTarget(istargeting,remtype,selfrange,opporange,remfilter,remtotal,funs[10],exc,remtotmax,funs[6])
	local operation=cm.RemovalOperation(istargeting,remtype,selfrange,opporange,remfilter,remtotal,funs[7],exc,remtotmax,funs[8],funs[11],funs[12],funs[13])
	local e1=cm.ActivateModule(c,event,typ,target,operation,funs[2],prop,range,funs[3],funs[4],funs[9],funs[10])
	c:RegisterEffect(e1)
	return e1
end
--CARD NUKE WHEN ACTIVATED: Remove (destroy,banish,bounce...) a card(s) from a specified location when activated
-- funs[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] : remtotal, Properties, Categories, Condition, Cost, Enable Exception, Additional Target conds, Enable Hopt, Enable OATH, forced
function cm.ActivateNuke(c,event,typ,range,remtype,remloc1,remloc2,remfilter,...)
	local funs={...}
	local categ,selfrange,opporange=0,0,0
	local exc=funs[5]
	if not funs[6] then exc=false end
	local evn,rmin
	if not funs[1] then rmin=1 else rmin=funs[1] end
	local cnew=CATEGORY_SEARCH+CATEGORY_TOHAND
	if remloc1&LOCATION_DECK==0 and remloc2&LOCATION_DECK==0 then cnew=CATEGORY_TOHAND end
	if funs[2] then
		categ=funs[2]+cnew
	else
		categ=cnew
	end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.NukeTarget(remtype,selfrange,opporange,remfilter,rmin,exc,funs[7],funs[10])
	local operation=cm.NukeOperation(remtype,selfrange,opporange,remfilter,rmin,exc)
	local e1=cm.ActivateModule(c,event,typ,target,operation,funs[3],funs[2],range,funs[4],funs[5],funs[8],funs[9])
	c:RegisterEffect(e1)
	return e1
end
--DAMAGE/RECOVER WHEN ACTIVATED
-- funs[1],[2],[3],[4],[5],[6],[7] : Properties, Categories, Condition, Cost, Additional Target conds, Enable Hopt, Enable OATH
function cm.ActivateLP(c,event,typ,range,amount,player,...)
	local funs={...}
	local prop=EFFECT_FLAG_PLAYER_TARGET
	local categ=0
	if funs[2] then
		categ=funs[2]
	end
	if amount>0 then
		categ=categ|CATEGORY_RECOVER
	else
		categ=categ|CATEGORY_DAMAGE
	end
	if funs[1] then
		prop=prop|funs[1]
	end
	local target=cm.LPTarget(categ,amount,player,funs[5])
	local operation=cm.LPOperation(amount)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,funs[3],funs[4],funs[6],funs[7])
	c:RegisterEffect(e1)
	return e1
end
--SPSUMMON WHEN ACTIVATED
-- funs[1],[2],[3],[4],[5],[6],[7],[8],[9] : Properties, Categories, Condition, Cost, Enable Exception, Additional Target conds, Target specs, Enable Hopt, Enable OATH, forced
-- [11],[12],[13]
function cm.ActivateSPSummon(c,event,typ,range,sumtype,istargeting,ssp,remloc1,remloc2,remfilter,remtotal,remtotmax,ignoresumcon,ignoresumct,sumpos,...)
	local funs={...}
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	if funs[2] then
		categ=funs[2]+CATEGORY_SPECIAL_SUMMON
	else
		categ=CATEGORY_SPECIAL_SUMMON
	end
	if istargeting then prop=prop+EFFECT_FLAG_CARD_TARGET end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.SPSummonTarget(sumtype,istargeting,ssp,selfrange,opporange,remfilter,remtotal,funs[10],exc,remtotmax,funs[6],ignoresumcon,ignoresumct,sumpos)
	local operation=cm.SPSummonOperation(sumtype,istargeting,ssp,selfrange,opporange,remfilter,remtotal,funs[7],exc,remtotmax,ignoresumcon,ignoresumct,sumpos,funs[11],funs[12],funs[13])
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,funs[3],funs[4],funs[8],funs[9])
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateSPSummonStep(c,event,typ,range,sumtype,step,istargeting,ssp,remloc1,remloc2,remfilter,remtotal,remtotmax,ignoresumcon,ignoresumct,sumpos,...)
	local funs={...}
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	if funs[2] then
		categ=funs[2]+CATEGORY_SPECIAL_SUMMON
	else
		categ=CATEGORY_SPECIAL_SUMMON
	end
	if istargeting then prop=prop+EFFECT_FLAG_CARD_TARGET end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.SPSummonTarget(sumtype,istargeting,ssp,selfrange,opporange,remfilter,remtotal,funs[10],exc,remtotmax,funs[6],ignoresumcon,ignoresumct,sumpos)
	local operation=cm.SPSummonStepOperation(sumtype,step,istargeting,ssp,selfrange,opporange,remfilter,remtotal,funs[7],exc,remtotmax,ignoresumcon,ignoresumct,sumpos,funs[11],funs[12],funs[13])
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,funs[3],funs[4],funs[8],funs[9])
	c:RegisterEffect(e1)
	return e1
end
--DRAW WHEN ACTIVATED
-- funs[1],[2],[3],[4],[5],[6],[7],[8] : Properties, Categories, Condition, Cost, Additional Target conds, Target specs, Enable Hopt, Enable OATH, forced
function cm.ActivateDraw(c,event,typ,range,amount,player,...)
	local funs={...}
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	if funs[2] then
		categ=funs[2]+CATEGORY_DRAW
	else
		categ=CATEGORY_DRAW
	end
	if not funs[11] then prop=prop+EFFECT_FLAG_PLAYER_TARGET end
	local target=cm.DrawTarget(categ,amount,player,funs[10],funs[5])
	local operation=cm.DrawOperation()
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,funs[3],funs[4],funs[8],funs[9])
	c:RegisterEffect(e1)
	return e1
end
--SEARCH
function cm.ActivateAddToHand(c,event,typ,range,istargeting,remloc1,remloc2,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local pro,cat,cond,cost,excep,addcon,tspec,baitdoll,hopt,oath,forced,conjword,conj,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14]
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=excep
	if not excep then exc=false end
	if pro then
		prop=prop|pro
	end
	local cnew=cm.CategRemTypeConverter("bounce")
	if remloc1&LOCATION_DECK~=0 then cnew=cnew|CATEGORY_SEARCH end
	if cat then
		categ=cat|cnew
	else
		categ=cnew
	end
	if istargeting then prop=prop|EFFECT_FLAG_CARD_TARGET end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.RemovalTarget(istargeting,"bounce",selfrange,opporange,remfilter,remtotal,forced,exc,remtotmax,addcon)
	local operation=cm.RemovalOperation(istargeting,"bounce",selfrange,opporange,remfilter,remtotal,tspec,exc,remtotmax,baitdoll,conjword,conj,also)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,cond,cost,hopt,oath)
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateSearch(c,event,typ,range,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local pro,cat,cond,cost,excep,addcon,tspec,baitdoll,hopt,oath,forced,conjword,conj,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14]
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=excep
	if not excep then exc=false end
	if pro then
		prop=prop|pro
	end
	local cnew=CATEGORY_SEARCH+CATEGORY_TOHAND
	if cat then
		categ=cat|cnew
	else
		categ=cnew
	end
	local target=cm.RemovalTarget(false,"bounce",LOCATION_DECK,0,cm.IsAbleToHand(remfilter),remtotal,forced,exc,remtotmax,addcon)
	local operation=cm.RemovalOperation(false,"bounce",LOCATION_DECK,0,cm.IsAbleToHand(remfilter),remtotal,tspec,exc,remtotmax,baitdoll,conjword,conj,also)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,cond,cost,hopt,oath)
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateFoolish(c,event,typ,range,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local pro,cat,cond,cost,excep,addcon,tspec,baitdoll,hopt,oath,forced,conjword,conj,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14]
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=excep
	if not excep then exc=false end
	if pro then
		prop=prop|pro
	end
	local cnew=CATEGORY_TOGRAVE
	if cat then
		categ=cat|cnew
	else
		categ=cnew
	end
	local target=cm.RemovalTarget(false,"tograve",LOCATION_DECK,0,cm.IsAbleToGrave(remfilter),remtotal,forced,exc,remtotmax,addcon)
	local operation=cm.RemovalOperation(false,"tograve",LOCATION_DECK,0,cm.IsAbleToGrave(remfilter),remtotal,tspec,exc,remtotmax,baitdoll,conjword,conj,also)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,cond,cost,hopt,oath)
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateGoldSarc(c,event,typ,range,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local pro,cat,cond,cost,excep,addcon,tspec,baitdoll,hopt,oath,forced,conjword,conj,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14]
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=excep
	if not excep then exc=false end
	if pro then
		prop=prop|pro
	end
	local cnew=CATEGORY_REMOVE
	if cat then
		categ=cat|cnew
	else
		categ=cnew
	end
	local target=cm.RemovalTarget(false,"banish",LOCATION_DECK,0,cm.IsAbleToRemove(remfilter),remtotal,forced,exc,remtotmax,addcon)
	local operation=cm.RemovalOperation(false,"banish",LOCATION_DECK,0,cm.IsAbleToRemove(remfilter),remtotal,tspec,exc,remtotmax,baitdoll,conjword,conj,also)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,cond,cost,hopt,oath)
	c:RegisterEffect(e1)
	return e1
end
function cm.ActivateSet(c,event,typ,range,tplayer,mode,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local pro,cat,cond,cost,excep,addcon,tspec,baitdoll,hopt,oath,forced,conjword,conj,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14]
	local categ,prop,selfrange,opporange=0,0,0,0
	local exc=excep
	if not excep then exc=false end
	local target=cm.SetTarget(false,tplayer,LOCATION_DECK,0,cm.IsAbleToSet(remfilter),remtotal,forced,exc,remtotmax,addcon)
	local operation=cm.SetOperation(false,tplayer,mode,LOCATION_DECK,0,cm.IsAbleToSet(remfilter),remtotal,tspec,exc,remtotmax,conjword,conj,also)
	local e1=cm.ActivateModule(c,event,typ,target,operation,categ,prop,range,cond,cost,hopt,oath)
	c:RegisterEffect(e1)
	return e1
end
------------------------------FullEffects Shortcuts-------------------------
------------------------------Effect Functions------------------------------
function cm.FMaterialFilter(func,...)
	local extra_params={...}
	return	function (c,e)
				return (not func or func(c,table.unpack(extra_params))) and not c:IsImmuneToEffect(e)
			end
end
function cm.ExtraFMaterial(func,...)
	local extra_params={...}
	return	function (c,e)
				return (not func or func(c,table.unpack(extra_params))) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
			end
end
function cm.FusionFilter(func,...)
	local extra_params={...}
	return	function (c,e,tp,m,include,chkf)
				return (not func or func(c,table.unpack(extra_params))) and c:IsType(TYPE_FUSION)
					and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,include,chkf)
			end
end
function cm.FCheck(mode,loc,ct)
	if mode=="atleast" then
		return	function (tp,sg,fc)
					return sg:FilterCount(Card.IsLocation,nil,loc)>=ct
				end
	elseif mode=="upto" then
		return	function (tp,sg,fc)
					return sg:FilterCount(Card.IsLocation,nil,loc)<=ct
				end
	end
end
function cm.GCheck(loc,ct)
	return	function (sg)
				return sg:FilterCount(Card.IsLocation,nil,loc)<=ct
			end
end
function cm.FusionTarget(polytype,fusfilter,matfilterfieldhand,...)
--[1]: other locations Materials / [2]: oppo's location materials / [3]: Category / [4]:Including this card as material /[5]FCheckAdditional /[6]GCheckAdditional
--/ [7] Condition for alternative materials / [8] Alternative Fusion Material under certain conditions / [9] Alternative Fusion Material under certain conditions (oppo) /[10] Alternative Procedure for Particular Fusion Monsters
--[11] Mats for the procedure (self) / [12] Mats for the procedure (oppo) / [13]: Fusion Monster Summonable by the Proc
	local funs={...}
	local extramat,oppomat,categ,include,fcheck,gcheck,altcon,altmat_u,altmat_uo,proc,procmat,procmat_o,procfusfilter=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13]
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					-----------
					local ffilter,fparams,mfilter,mparams
					if type(fusfilter(1))=="table" then
						ffilter,fparams=fusfilter(0),fusfilter(1)
						cm.ParamConverter(fparams,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						ffilter=fusfilter
						fparams={}
					end
					if matfilterfieldhand then
						if type(matfilterfieldhand(1))=="table" then
							mfilter,mparams=matfilterfieldhand(0),matfilterfieldhand(1)
							cm.ParamConverter(mparams,e,tp,eg,ep,ev,re,r,rp,chk)
						else
							mfilter=matfilterfieldhand
							mparams={}
						end
					end
					-----------
					local chkf=tp
					local mg1,mgx
					if mfilter then
						if type(mfilter)=="function" then
							mg1=Duel.GetFusionMaterial(tp):Filter(mfilter,nil,table.unpack(mparams))
						else
							mg1=Duel.GetFusionMaterial(tp)
						end
					else
						mg1=Group.CreateGroup()
					end
					--Debug.Message(tostring(#mg1))
					if extramat then
						for loc,extrafilter in pairs(extramat) do
							local efilter,eparams
							if type(extrafilter(1))=="table" then
								efilter,eparams=extrafilter(0),extrafilter(1)
								cm.ParamConverter(eparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								efilter=extrafilter
								eparams={}
							end
							local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(efilter,table.unpack(eparams)),tp,loc,0,nil,e)
							mg1:Merge(mg2)
						end
					end
					if oppomat then
						for loc,oppofilter in pairs(oppomat) do
							local ofilter,oparams
							if type(oppofilter(1))=="table" then
								ofilter,oparams=oppofilter(0),oppofilter(1)
								cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								ofilter=oppofilter
								oparams={}
							end
							local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
							mg1:Merge(mg2)
						end
					end
					local okcheck=false
					--Alternative Materials under exclusive conditions
					if altcon and altcon(e,tp,eg,ep,ev,re,r,rp) then
						if altmat_u then
							for loc,filter in pairs(altmat_u) do
								local ofilter,oparams
								if type(filter(1))=="table" then
									ofilter,oparams=filter(0),filter(1)
									cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
								else
									ofilter=filter
									oparams={}
								end
								local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),tp,loc,0,nil,e)
								mg1:Merge(mg2)
								--Debug.Message(tostring(#mg1))
								okcheck=true
							end
						end
						if altmat_uo then
							for loc,filter in pairs(altmat_uo) do
								local ofilter,oparams
								if type(filter(1))=="table" then
									ofilter,oparams=filter(0),filter(1)
									cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
								else
									ofilter=filter
									oparams={}
								end
								local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
								mg1:Merge(mg2)
								okcheck=true
							end
						end
					end
					----------------------
					local inc=nil
					if include then
						if include=="equip" then
							inc=e:GetHandler():GetEquipTarget()
						elseif include=="target" then
							inc=e:GetHandler():GetTargetCard()
						else
							inc=e:GetHandler()
						end
					end
					if fcheck and okcheck then Auxiliary.FCheckAdditional=cm.FCheck(fcheck[1],fcheck[2],fcheck[3]) end
					if gcheck and okcheck then Auxiliary.GCheckAdditional=cm.GCheck(gcheck[1],gcheck[2]) end
					local res=Duel.IsExistingMatchingCard(cm.FusionFilter(ffilter,table.unpack(fparams)),tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,inc,chkf)
					Auxiliary.FCheckAdditional=nil
					Auxiliary.GCheckAdditional=nil
					--Alternative Proc for particular Fusions
					if proc then
						if res then return true end
						if procmat then
							for loc,filter in pairs(procmat) do
								local ofilter,oparams
								if type(filter(1))=="table" then
									ofilter,oparams=filter(0),filter(1)
									cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
								else
									ofilter=filter
									oparams={}
								end
								mgx=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),tp,loc,0,nil,e)
								mgx:Merge(mg1)
							end
						end
						if procmat_o then
							for loc,filter in pairs(procmat_o) do
								local ofilter,oparams
								if type(filter(1))=="table" then
									ofilter,oparams=filter(0),filter(1)
									cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
								else
									ofilter=filter
									oparams={}
								end
								mgx=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
								mgx:Merge(mg1)
							end
						end
						local fffilter,ffparams
						if type(procfusfilter(1))=="table" then
							fffilter,ffparams=procfusfilter(0),procfusfilter(1)
							cm.ParamConverter(ffparams,e,tp,eg,ep,ev,re,r,rp,nil)
						else
							fffilter=procfusfilter
							ffparams={}
						end
						res=Duel.IsExistingMatchingCard(cm.FusionFilter(procfusfilter,table.unpack(ffparams)),tp,LOCATION_EXTRA,0,1,nil,e,tp,mgx,nil,chkf)
					end
					--
					if not res then
						local ce=Duel.GetChainMaterial(tp)
						if ce~=nil then
							local fgroup=ce:GetTarget()
							local mge=fgroup(ce,e,tp)
							local mf=ce:GetValue()
							res=Duel.IsExistingMatchingCard(cm.FusionFilter(ffilter,table.unpack(fparams)),tp,LOCATION_EXTRA,0,1,nil,e,tp,mge,mf,chkf)
						end
					end
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
				if categ and type(categ)=="table" then
					local categcount=1
					for k,v in pairs(categ) do
						if v~=0 then
							local p=tp
							if math.modf(categcount,2)==0 then p=1-tp end
							Duel.SetOperationInfo(0,k,nil,1,p,v)
						end
					end
				end
						
	end
end
function cm.FusionOperation(polytype,fusfilter,matfilterfieldhand,...)
	--[1]: other locations Materials / [2]: oppo's location materials / [3]: Including this card as material / [4] FCheckAdditional / [5]GCheckAdditional
	--/ [6] Condition for alternative materials / [7] Alternative Fusion Material under certain conditions / [8] Alternative Fusion Material under certain conditions (oppo)
	--/[9] Alternative Procedure for Particular Fusion Monsters / [10] Mats for the procedure (self) / [11] Mats for the procedure (oppo) / [12]: Fusion Monster Summonable by the Proc
--	/ [13] Pre-Resolution Check / [14]: Pre-Summon Operation (changes to the Fusion Monster) / [15] Conjuncted effect
	local funs={...}
	local extramat,oppomat,include,fcheck,gcheck,altcon,altmat_u,altmat_uo,proc,procmat,procmat_o,procfusfilter,check,presum,conjunction=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12],funs[13],funs[14],funs[15]
	return	function (e,tp,eg,ep,ev,re,r,rp)
				-----------
				local ffilter,fparams,mfilter,mparams
				if type(fusfilter(1))=="table" then
					ffilter,fparams=fusfilter(0),fusfilter(1)
					cm.ParamConverter(fparams,e,tp,eg,ep,ev,re,r,rp,nil)
				else
					ffilter=fusfilter
					fparams={}
				end
				if matfilterfieldhand then
					if type(matfilterfieldhand(1))=="table" then
						mfilter,mparams=matfilterfieldhand(0),matfilterfieldhand(1)
						cm.ParamConverter(mparams,e,tp,eg,ep,ev,re,r,rp,nil)
					else
						mfilter=matfilterfieldhand
						mparams={}
					end
				end
				-----------
				if check and not check(e,tp,eg,ep,ev,re,r,rp) then return end
				local inc=nil
				if include then
					if include=="equip" then
						inc=e:GetHandler():GetEquipTarget()
					elseif include=="target" then
						inc=e:GetHandler():GetTargetCard()
					else
						inc=e:GetHandler()
					end
				end
				local chkf=tp
				local mg1,mgx
				if mfilter then
					if type(mfilter)=="function" then
						mg1=Duel.GetFusionMaterial(tp):Filter(cm.FMaterialFilter(mfilter,table.unpack(mparams)),nil,e)
					else
						mg1=Duel.GetFusionMaterial(tp):Filter(cm.FMaterialFilter(false),nil,e)
					end
				else
					mg1=Group.CreateGroup()
				end
				local exmat=false
				if extramat then
					for loc,extrafilter in pairs(extramat) do
						local efilter,eparams
						if type(extrafilter(1))=="table" then
							efilter,eparams=extrafilter(0),extrafilter(1)
							cm.ParamConverter(eparams,e,tp,eg,ep,ev,re,r,rp,nil)
						else
							efilter=extrafilter
							eparams={}
						end
						local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(efilter,table.unpack(eparams)),tp,loc,0,nil,e)
						mg1:Merge(mg2)
					end
				end
				if oppomat then
					for loc,oppofilter in pairs(oppomat) do
						local ofilter,oparams
						if type(oppofilter(1))=="table" then
							ofilter,oparams=oppofilter(0),oppofilter(1)
							cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,nil)
						else
							ofilter=oppofilter
							oparams={}
						end
						local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
						mg1:Merge(mg2)
					end
				end
				--Alternative Condition Materials
				if altcon and altcon(e,tp,eg,ep,ev,re,r,rp) then
					if altmat_u then
						for loc,filter in pairs(altmat_u) do
							local ofilter,oparams
							if type(filter(1))=="table" then
								ofilter,oparams=filter(0),filter(1)
								cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								ofilter=filter
								oparams={}
							end
							local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),tp,loc,0,nil,e)
							mg1:Merge(mg2)
							exmat=true
						end
					end
					if altmat_uo then
						for loc,filter in pairs(altmat_uo) do
							local ofilter,oparams
							if type(filter(1))=="table" then
								ofilter,oparams=filter(0),filter(1)
								cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								ofilter=filter
								oparams={}
							end
							local mg2=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
							mg1:Merge(mg2)
							exmat=true
						end
					end
				end
				--Alternative Proc for particular Fusions
				local location_proc=0
				if proc then
					if res then return true end
					if procmat then
						for loc,filter in pairs(procmat) do
							local ofilter,oparams
							if type(filter(1))=="table" then
								ofilter,oparams=filter(0),filter(1)
								cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								ofilter=filter
								oparams={}
							end
							mgx=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),tp,loc,0,nil,e)
							mgx:Merge(mg1)
							local fixloc=loc-(location_proc&loc)
							location_proc=location_proc+fixloc
						end
					end
					if procmat_o then
						for loc,filter in pairs(procmat_o) do
							local ofilter,oparams
							if type(filter(1))=="table" then
								ofilter,oparams=filter(0),filter(1)
								cm.ParamConverter(oparams,e,tp,eg,ep,ev,re,r,rp,chk)
							else
								ofilter=filter
								oparams={}
							end
							mgx=Duel.GetMatchingGroup(cm.ExtraFMaterial(ofilter,table.unpack(oparams)),1-tp,loc,0,nil,e)
							mgx:Merge(mg1)
							local fixloc=loc-(location_proc&loc)
							location_proc=location_proc+fixloc
						end
					end
				end
				--
				if exmat then
					if fcheck then Auxiliary.FCheckAdditional=cm.FCheck(fcheck[1],fcheck[2],fcheck[3]) end
					if gcheck then Auxiliary.GCheckAdditional=cm.GCheck(gcheck[1],gcheck[2]) end
				end
				local sg1=Duel.GetMatchingGroup(cm.FusionFilter(ffilter,table.unpack(fparams)),tp,LOCATION_EXTRA,0,nil,e,tp,mg1,inc,chkf)
				--Debug.Message(tostring(#sg1))
				if procfusfilter then
					local fffilter,ffparams
					if type(procfusfilter(1))=="table" then
						fffilter,ffparams=procfusfilter(0),procfusfilter(1)
						cm.ParamConverter(ffparams,e,tp,eg,ep,ev,re,r,rp,nil)
					else
						fffilter=procfusfilter
						ffparams={}
					end
					local sg2=Duel.GetMatchingGroup(cm.FusionFilter(procfusfilter,table.unpack(ffparams)),tp,LOCATION_EXTRA,0,nil,e,tp,mgx,nil,chkf)
					sg1:Merge(sg2)
				end
				Auxiliary.FCheckAdditional=nil
				Auxiliary.GCheckAdditional=nil
				local mge=nil
				local sge=nil
				local ce=Duel.GetChainMaterial(tp)
				if ce~=nil then
					local fgroup=ce:GetTarget()
					mge=fgroup(ce,e,tp)
					local mf=ce:GetValue()
					sge=Duel.GetMatchingGroup(cm.FusionFilter(ffilter,table.unpack(fparams)),tp,LOCATION_EXTRA,0,nil,e,tp,mge,mf,inc,chkf)
				end
				if sg1:GetCount()>0 or (sge~=nil and sge:GetCount()>0) then
					local sg=sg1:Clone()
					if sge then sg:Merge(sge) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tg=sg:Select(tp,1,1,nil)
					local tc=tg:GetFirst()
					mg1:RemoveCard(tc)
					local res=false
					if presum then presum(tc,e,tp,eg,ep,ev,re,r,rp) end
					if sg1:IsContains(tc) and (sge==nil or not sge:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
						if exmat then
							if fcheck then Auxiliary.FCheckAdditional=cm.FCheck(fcheck[1],fcheck[2],fcheck[3]) end
							if gcheck then Auxiliary.GCheckAdditional=cm.GCheck(gcheck[1],gcheck[2]) end
						end
						if proc then
							local fffilter,ffparams
							if type(procfusfilter(1))=="table" then
								fffilter,ffparams=procfusfilter(0),procfusfilter(1)
								cm.ParamConverter(ffparams,e,tp,eg,ep,ev,re,r,rp,nil)
							else
								fffilter=procfusfilter
								ffparams={}
							end
							if procfusfilter(tc,table.unpack(ffparams)) then
								local mat1=Duel.SelectFusionMaterial(tp,tc,mgx,nil,chkf)
								tc:SetMaterial(mat1)
								local mat2=mat1:Filter(Card.IsLocation,nil,location_proc)
								mat1:Sub(mat2)
								cm.FusionConverter(mat1,polytype,e,tp,eg,ep,ev,re,r,rp)
								cm.FusionConverter(mat2,proc,e,tp,eg,ep,ev,re,r,rp)
								Duel.BreakEffect()
								Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
								res=true
							else
								local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
								tc:SetMaterial(mat2)
								cm.FusionConverter(mat2,polytype,e,tp,eg,ep,ev,re,r,rp)
								Duel.BreakEffect()
								Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
								res=true
							end
						else
							local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
							Auxiliary.FCheckAdditional=nil
							Auxiliary.GCheckAdditional=nil
							tc:SetMaterial(mat1)
							cm.FusionConverter(mat1,polytype,e,tp,eg,ep,ev,re,r,rp)
							Duel.BreakEffect()
							Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
							res=true
						end
					else
						local mat2=Duel.SelectFusionMaterial(tp,tc,mge,nil,chkf)
						local fop=ce:GetOperation()
						fop(ce,e,tp,tc,mat2)
						res=true
					end
					if res then
						tc:CompleteProcedure()
						if conjunction then
							conjunction(c,tc,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
	end
end
function cm.LPTarget(categ,amount,player,...)
	local funs={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local pl=0
				if player==0 then pl=tp else pl=1-tp end
				if chk==0 then
					return (not funs[1] or funs[1](e,tp,eg,ep,ev,re,r,rp))
				end
				Duel.SetTargetPlayer(pl)
				Duel.SetTargetParam(math.abs(amount))
				Duel.SetOperationInfo(0,categ,nil,0,pl,math.abs(amount))
			end
end
function cm.LPOperation(amount)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				if amount>0 then
					Duel.Recover(p,d,REASON_EFFECT)
				elseif amount<0 then
					Duel.Damage(p,math.abs(d),REASON_EFFECT)
				else
					return
				end
			end
end
		
function cm.RemovalTarget(istargeting,remtype,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: forced, exception, max target number, additional target chk conds
	local funs={...}
	local excep=nil
	local remtotmax=funs[3]
	if not funs[3] then remtotmax=remtotal end
	local hint,categ=0,0
	if remtype=="destroy" then hint=HINTMSG_DESTROY categ=CATEGORY_DESTROY
		elseif (remtype=="banish" or remtype=="banishfacedown") then hint=HINTMSG_REMOVE categ=CATEGORY_REMOVE
		elseif remtype=="bounce" then hint=HINTMSG_RTOHAND categ=CATEGORY_TOHAND
		elseif remtype=="spin" then hint=HINTMSG_TODECK categ=CATEGORY_TODECK
		elseif remtype=="tograve" then hint=HINTMSG_TOGRAVE categ=CATEGORY_TOGRAVE
		elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then hint=HINTMSG_POSITION categ=CATEGORY_POSITION
	end
	if istargeting then
		local chkloc=0
		if remloc1&remloc2~=0 then chkloc=remloc1&remloc2 end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					if chkc then
						local chkcloc,affectp=chkc:IsLocation(remloc1+remloc2-chkloc),true
						if remloc1>0 and remloc2==0 then affectp=chkc:IsControler(tp)
						elseif remloc1==0 and remloc2>0 then affectp=chkc:IsControler(1-tp)
						else chkcloc,affectp=true,true
						end
						return chkcloc and affectp and (not filter or filter(chkc,table.unpack(params))) 
					end
					if chk==0 then
						local check
						if funs[1] then 
							check=true
						else
							check=Duel.IsExistingTarget(filter,tp,remloc1,remloc2,remtotal,excep,table.unpack(params))
						end
						return check and (not funs[4] or funs[4](e,tp,eg,ep,ev,re,r,rp))
					end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectTarget(tp,filter,tp,remloc1,remloc2,remtotal,remtotmax,excep,table.unpack(params))
					Duel.SetOperationInfo(0,categ,g,remtotal,0,0)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					if chk==0 then
						local check
						if funs[1] then 
							check=true
						else
							check=Duel.IsExistingMatchingCard(filter,tp,remloc1,remloc2,remtotal,excep,table.unpack(params))
						end
						return check and (not funs[4] or funs[4](e,tp,eg,ep,ev,re,r,rp))
					end
					local g=Duel.GetMatchingGroup(filter,tp,remloc1,remloc2,excep,table.unpack(params))
					if remloc1~=0 then
						Duel.SetOperationInfo(0,categ,nil,remtotal,tp,remloc1)
					end
					if remloc2~=0 then
						Duel.SetOperationInfo(0,categ,nil,remtotal,1-tp,remloc2)
					end
				end
	end
end
function cm.RemovalOperation(istargeting,remtype,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: target specifications, exception, max target number, BaitDollConfirmation, "andifyoudo" or "then", conjuncted effect, "also" effect
	local funs={...}
	local resolve=true
	local conj=false
	local excep=nil
	local remtotmax=funs[3]
	if not funs[3] then remtotmax=remtotal end
	local hint,categ=0,0
	if remtype=="destroy" then hint=HINTMSG_DESTROY categ=CATEGORY_DESTROY 
	elseif (remtype=="banish" or remtype=="banishfacedown") then hint=HINTMSG_REMOVE categ=CATEGORY_REMOVE
	elseif remtype=="bounce" then hint=HINTMSG_RTOHAND categ=CATEGORY_TOHAND
	elseif (remtype=="spin" or remtype=="spintop" or remtype=="spinbottom") then hint=HINTMSG_TODECK categ=CATEGORY_TODECK
	elseif remtype=="tograve" then hint=HINTMSG_TOGRAVE categ=CATEGORY_TOGRAVE
	elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then hint=HINTMSG_POSITION categ=CATEGORY_POSITION
	end
	if istargeting then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp)
					else
						filter=remfilter
						params={}
					end
					local tc,tcheck,tgt=nil,nil,nil
					if remtotmax==1 then
						tc=Duel.GetFirstTarget()
						tcheck=(tc:IsRelateToEffect(e) and (not funs[1] or funs[1](tc,e,tp)))
					else
						tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Glitchy.MultipleTargetsCheck,nil,e,funs[1],tp)
						tcheck=(#tc>0)
					end
					if tcheck then
						if funs[4] then
							if remtotmax==1 then
								if tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
								if not funs[4](tc,e,tp,eg,ep,ev,re,r,rp) then resolve=false end
							else
								local tgg=tc:Filter(Card.IsFacedown,nil)
								if #tgg>0 then Duel.ConfirmCards(tp,tgg) end
								tgt=tgg:Filter(funs[4],nil,tc,e,tp,eg,ep,ev,re,r,rp)
								if #tgt<=0 then resolve=false end
							end
						end
						if not resolve then return end
						if tgt then tc=tgt end
						if remtype=="destroy" then if Duel.Destroy(tc,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="banish" then if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="banishfacedown" then if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="bounce" then if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
							if Duel.GetOperatedGroup()>1 then
								local gtc=Duel.GetOperatedGroup():Filter(function (c) return bit.band(c:GetPreviousLocation(),LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_HAND)>0 end,nil)
								if #gtc>0 then
									Duel.ConfirmCards(1-tp,gtc) 
								end
							else
								if bit.band(tc:GetPreviousLocation(),LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_HAND)>0 then 
									Duel.ConfirmCards(1-tc:GetControler(),tc) 
								end
							end
							conj=true end
						elseif remtype=="spin" then
							if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
								conj=true
								if remtotmax==1 and tc:IsLocation(LOCATION_DECK) then
									Duel.ShuffleDeck(tc:GetControler())
								elseif remtotmax>1 then
									for p=0,1 do
										if tc:IsExists(Glitchy.ShuffleCheck,1,nil,p) then
											Duel.ShuffleDeck(p)
										end
									end
								end
							end
						elseif remtype=="spintop" and remtotmax==1 then if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="spinbottom" and remtotmax==1 then if Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="tograve" then if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then conj=true end
						elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then if Duel.ChangePosition(tc,cm.PositionConverter(remtype))~=0 then conj=true end
						end
						if funs[5] and ((funs[5]=="andifyoudo" and conj) or (funs[5]=="then")) then
							funs[6](e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if funs[7] then
						funs[7](e,tp,eg,ep,ev,re,r,rp)
					end
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(filter),tp,remloc1,remloc2,remtotal,remtotmax,excep,table.unpack(params))
					if g:GetCount()>0 then
						local ghint=g:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_DECK+LOCATION_EXTRA)
						Duel.HintSelection(ghint)
						if funs[4] then
							if g:GetFirst():IsFacedown() then Duel.ConfirmCards(tp,g:GetFirst()) end
							if not tc:IsType(funs[4]) then resolve=false end
						end
						if not resolve then return end
						if remtype=="destroy" then if Duel.Destroy(g,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="banish" then if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="banishfacedown" then if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="bounce" then if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then 
							local gtc=Duel.GetOperatedGroup():Filter(function (c) return bit.band(c:GetPreviousLocation(),LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_HAND)>0 end,nil)
							if #gtc>0 then 
								Duel.ConfirmCards(1-tp,gtc) 
							end 
							conj=true 
						end
						elseif remtype=="spin" then
							if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
								conj=true
								for p=0,1 do
									if g:IsExists(Glitchy.ShuffleCheck,1,nil,p) then
										Duel.ShuffleDeck(p)
									end
								end
							end
						elseif remtype=="spintop" and #g==1 then if Duel.SendtoDeck(g,nil,0,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="spinbottom" and #g==1 then if Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then conj=true end
						elseif remtype=="tograve" then if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then conj=true end
						elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then if Duel.ChangePosition(g,cm.PositionConverter(remtype))~=0 then conj=true end
						end
						if funs[5] and ((funs[5]=="andifyoudo" and conj) or (funs[5]=="then")) then
							funs[6](e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if funs[7] then
						funs[7](e,tp,eg,ep,ev,re,r,rp)
					end
				end
	end
end
--NUKE EFFECTS
function cm.NukeTarget(remtype,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: exception, additional target chk conds, forced eff
	local funs={...}
	local forced=funs[3]
	local excep=nil
	local hint,categ=0,0
	if remtype=="destroy" then hint=HINTMSG_DESTROY categ=CATEGORY_DESTROY
		elseif (remtype=="banish" or remtype=="banishfacedown") then hint=HINTMSG_REMOVE categ=CATEGORY_REMOVE
		elseif remtype=="bounce" then hint=HINTMSG_RTOHAND categ=CATEGORY_TOHAND
		elseif remtype=="spin" then hint=HINTMSG_TODECK categ=CATEGORY_TODECK
		elseif remtype=="tograve" then hint=HINTMSG_TOGRAVE categ=CATEGORY_TOGRAVE
		elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then hint=HINTMSG_POSITION categ=CATEGORY_POSITION
	end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local filter,params
				if type(remfilter(1))=="table" then
					filter,params=remfilter(0),remfilter(1)
					cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
				else
					filter=remfilter
					params={}
				end
				if funs[1] then excep=e:GetHandler() end
				if chk==0 then
					if forced then
						return true
					else
						local check=(Duel.IsExistingMatchingCard(filter,tp,remloc1,remloc2,remtotal,excep,table.unpack(params)))
						return check and (not funs[2] or funs[2](e,tp,eg,ep,ev,re,r,rp))
					end
				end
				local g=Duel.GetMatchingGroup(filter,tp,remloc1,remloc2,excep,table.unpack(params))
				Duel.SetOperationInfo(0,categ,g,#g,0,0)
			end
end
function cm.NukeOperation(remtype,remloc1,remloc2,remfilter,...)
	--funs[1]: exception
	local funs={...}
	local excep=nil
	local hint,categ=0,0
	if remtype=="destroy" then hint=HINTMSG_DESTROY categ=CATEGORY_DESTROY 
	elseif (remtype=="banish" or remtype=="banishfacedown") then hint=HINTMSG_REMOVE categ=CATEGORY_REMOVE
	elseif remtype=="bounce" then hint=HINTMSG_RTOHAND categ=CATEGORY_TOHAND
	elseif (remtype=="spin" or remtype=="spintop" or remtype=="spinbottom") then hint=HINTMSG_TODECK categ=CATEGORY_TODECK
	elseif remtype=="tograve" then hint=HINTMSG_TOGRAVE categ=CATEGORY_TOGRAVE
	elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then hint=HINTMSG_POSITION categ=CATEGORY_POSITION
	end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local filter,params
				if type(remfilter(1))=="table" then
					filter,params=remfilter(0),remfilter(1)
					cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
				else
					filter=remfilter
					params={}
				end
				if funs[1] then excep=e:GetHandler() end
				local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(filter),tp,remloc1,remloc2,excep,table.unpack(params))
				if #g>0 then
					if remtype=="destroy" then Duel.Destroy(g,REASON_EFFECT)
					elseif remtype=="banish" then Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
					elseif remtype=="banishfacedown" then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
					elseif remtype=="bounce" then Duel.SendtoHand(g,nil,REASON_EFFECT)
					elseif remtype=="spin" then
						if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
							for p=0,1 do
								if g:IsExists(Glitchy.ShuffleCheck,1,nil,p) then
									Duel.ShuffleDeck(p)
								end
							end
						end
					elseif remtype=="tograve" then Duel.SendtoGrave(g,REASON_EFFECT)
					elseif (remtype=="posUA" or remtype=="posUD" or remtype=="posDA"  or remtype=="posDD" or remtype=="position" or remtype=="flipup" or remtype=="flipupsetavailable") then Duel.ChangePosition(g,cm.PositionConverter(remtype))
					end
				end
			end
end
--SPSUMMONING
function cm.SPSummonFilter(func,sumtype,ignoresumcon,ignoresumct,sumpos,sumplayer,...)
	local extra_params={...}
	return	function (c,e,tp)
				local sumcon,sumct,pos,p
				if not ignoresumcon then sumcon=false end
				if not ignoresumct then sumct=false end
				if not sumpos then pos=POS_FACEUP else pos=sumpos end
				if sumplayer==0 then p=tp else p=1-tp end
				return (not func or func(c,table.unpack(extra_params))) and c:IsCanBeSpecialSummoned(e,sumtype,tp,sumcon,sumct,pos,p)
			end
end
function cm.SPSummonTarget(sumtype,istargeting,ssp,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4],[5],[6],[7]: forced, exception, max target number, additional target chk conds, ignoresumcon, ignoresumct, sumpos
	local funs={...}
	local forced,excep,remtotmax,addcheck,ignoresumcon,ignoresumct,sumpos=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7]
	if not forced then forced=false end
	if not funs[3] then remtotmax=remtotal end
	local hint,categ=0,0
	local p=0
	if istargeting then
		local chkloc=0
		if remloc1&remloc2~=0 then chkloc=remloc1&remloc2 end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if chkc then
						local chkcloc,affectp=chkc:IsLocation(remloc1+remloc2-chkloc),true
						if remloc1>0 and remloc2==0 then affectp=chkc:IsControler(tp)
						elseif remloc1==0 and remloc2>0 then affectp=chkc:IsControler(1-tp)
						else chkcloc,affectp=true,true
						end
						local checkedfilter=cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params))
						return chkcloc and affectp and checkedfilter(chkc,e,tp)
					end
					local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
					if ft<remtotal then return end
					if ft>remtotmax then ft=remtotmax end
					if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
					if chk==0 then
						local check
						if remtotal==1 then
							check=((Duel.GetLocationCount(p,LOCATION_MZONE)+1)>remtotal and Duel.IsExistingTarget(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params)),tp,remloc1,remloc2,remtotal,excep,e,tp))
						else
							check=((Duel.GetLocationCount(p,LOCATION_MZONE)+1)>remtotal and Duel.IsExistingTarget(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params)),tp,remloc1,remloc2,remtotal,excep,e,tp)
								and not Duel.IsPlayerAffectedByEffect(tp,59822133))
						end
						return forced or (check and (not addcheck or addcheck(e,tp,eg,ep,ev,re,r,rp)))
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params))),tp,remloc1,remloc2,remtotal,ft,excep,e,tp)
					Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,remtotal,0,0)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if chk==0 then
						local check
						if remtotal==1 then
							check=((Duel.GetLocationCount(p,LOCATION_MZONE)+1)>remtotal and Duel.IsExistingMatchingCard(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params)),tp,remloc1,remloc2,remtotal,excep,e,tp))
						else
							check=((Duel.GetLocationCount(p,LOCATION_MZONE)+1)>remtotal and Duel.IsExistingMatchingCard(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params)),tp,remloc1,remloc2,remtotal,excep,e,tp)
								and not Duel.IsPlayerAffectedByEffect(tp,59822133))
						end
						return forced or (check and (not addcheck or addcheck(e,tp,eg,ep,ev,re,r,rp)))
					end
					local g=Duel.GetMatchingGroup(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params)),tp,remloc1,remloc2,excep,e,tp)
					if remloc1~=0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,remtotal,tp,remloc1)
					end
					if remloc2~=0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,remtotal,1-tp,remloc2)
					end
				end
	end
end
function cm.SPSummonOperation(sumtype,istargeting,ssp,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: target specifications, exception, max target number
	local funs={...}
	local tspec,excep,remtotmax,ignoresumcon,ignoresumct,sumpos,conjword,conjunct,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9]
	if not funs[3] then remtotmax=remtotal end
	local p=0
	local conj=false
	if istargeting then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					local tc,tcheck=nil,nil
					if remtotmax==1 then
						tc=Duel.GetFirstTarget()
						tcheck=(Duel.GetLocationCount(p,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and (not tspec or tspec(tc,e,tp)))
					else
						tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Glitchy.MultipleTargetsCheck,nil,e,tspec,tp)
						local tcheck_sub
						if #tc>1 then
							tcheck_sub=Duel.IsPlayerAffectedByEffect(tp,59822133)
						end
						tcheck=(Duel.GetLocationCount(p,LOCATION_MZONE)>#tc and #tc>0 and not tcheck_sub)
					end
					if tcheck then
						local sumcon,sumct,pos,p
						if not ignoresumcon then sumcon=false end
						if not ignoresumct then sumct=false end
						if not sumpos then pos=POS_FACEUP end
						if Duel.SpecialSummon(tc,sumtype,tp,p,sumcon,sumct,sumpos)~=0 then conj=true end
						if conjword and ((conjword=="andifyoudo" and conj) or (conjword=="then")) then
							conjunct(e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if also then
						also(e,tp,eg,ep,ev,re,r,rp)
					end
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
					if ft<remtotal then return end
					if ft>remtotmax then ft=remtotmax end
					if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params))),tp,remloc1,remloc2,remtotal,ft,excep,e,tp)
					if g:GetCount()>0 then
						local sumcon,sumct,pos
						if not ignoresumcon then sumcon=false end
						if not ignoresumct then sumct=false end
						if not sumpos then pos=POS_FACEUP end
						if Duel.SpecialSummon(g,sumtype,tp,p,sumcon,sumct,sumpos)~=0 then conj=true end
						if conjword and ((conjword=="andifyoudo" and conj) or (conjword=="then")) then
							conjunct(e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if also then
						also(e,tp,eg,ep,ev,re,r,rp)
					end
				end
	end
end
function cm.SPSummonStepOperation(sumtype,step,istargeting,ssp,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: target specifications, exception, max target number
	local funs={...}
	local tspec,excep,remtotmax,ignoresumcon,ignoresumct,sumpos,conjword,conjunct,also=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9]
	if not funs[3] then remtotmax=remtotal end
	local p=0
	local conj=false
	if istargeting then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					local tc,tcheck=nil,nil
					if remtotmax==1 then
						tc=Duel.GetFirstTarget()
						tcheck=(Duel.GetLocationCount(p,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and (not tspec or tspec(tc,e,tp)))
					else
						tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Glitchy.MultipleTargetsCheck,nil,e,tspec,tp)
						local tcheck_sub
						if #tc>1 then
							tcheck_sub=Duel.IsPlayerAffectedByEffect(tp,59822133)
						end
						tcheck=(Duel.GetLocationCount(p,LOCATION_MZONE)>#tc and #tc>0 and not tcheck_sub)
					end
					if tcheck then
						if tc==1 then
							local sumcon,sumct,pos,p
							if not ignoresumcon then sumcon=false end
							if not ignoresumct then sumct=false end
							if not sumpos then pos=POS_FACEUP end
							if Duel.SpecialSummonStep(tc,sumtype,tp,p,sumcon,sumct,sumpos) then 
								step(e,tp,eg,ep,ev,re,r,rp,tc)
								Duel.SpecialSummonComplete()
								conj=true 
							end
						else
							local ct=0
							for tctc in aux.Next(tc) do 
								local sumcon,sumct,pos,p
								if not ignoresumcon then sumcon=false end
								if not ignoresumct then sumct=false end
								if not sumpos then pos=POS_FACEUP end
								if Duel.SpecialSummonStep(tctc,sumtype,tp,p,sumcon,sumct,sumpos) then 
									step(e,tp,eg,ep,ev,re,r,rp,tctc)
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							if ct==#tc then conj=true end
						end
						if conjword and ((conjword=="andifyoudo" and conj) or (conjword=="then")) then
							conjunct(e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if also then
						also(e,tp,eg,ep,ev,re,r,rp)
					end
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if ssp==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
					if ft<remtotal then return end
					if ft>remtotmax then ft=remtotmax end
					if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.SPSummonFilter(filter,sumtype,ignoresumcon,ignoresumct,sumpos,ssp,table.unpack(params))),tp,remloc1,remloc2,remtotal,ft,excep,e,tp)
					if g:GetCount()>0 then
						local ct=0
						for tc in aux.Next(g) do
							local sumcon,sumct,pos
							if not ignoresumcon then sumcon=false end
							if not ignoresumct then sumct=false end
							if not sumpos then pos=POS_FACEUP end
							if Duel.SpecialSummonStep(tc,sumtype,tp,p,sumcon,sumct,sumpos) then 
								step(e,tp,eg,ep,ev,re,r,rp,tctc)
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						if ct==#g then conj=true end
						if conjword and ((conjword=="andifyoudo" and conj) or (conjword=="then")) then
							conjunct(e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if also then
						also(e,tp,eg,ep,ev,re,r,rp)
					end
				end
	end
end
--DRAW
function cm.DrawTarget(categ,amount,player,...)
	local funs={...}
	local forced,addcheck=funs[1],funs[2]
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local pl=0
				if player==0 then pl=tp else pl=1-tp end
				if chk==0 then
					local check=Duel.IsPlayerCanDraw(player,amount)
					return forced or (check and (not addcheck or addcheck(e,tp,eg,ep,ev,re,r,rp)))
				end
				Duel.SetTargetPlayer(pl)
				Duel.SetTargetParam(math.abs(amount))
				Duel.SetOperationInfo(0,categ,nil,0,pl,amount)
			end
end
function cm.DrawOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				Duel.Draw(p,d,REASON_EFFECT)
			end
end
--SET
function cm.SetTarget(istargeting,tplayer,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: forced, exception, max target number, additional target chk conds
	local funs={...}
	local excep=nil
	local remtotmax=funs[3]
	if not funs[3] then remtotmax=remtotal end
	local hint,categ=0,0
	if istargeting then
		local chkloc=0
		if remloc1&remloc2~=0 then chkloc=remloc1&remloc2 end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					if tplayer==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					if chkc then
						local chkcloc,affectp=chkc:IsLocation(remloc1+remloc2-chkloc),true
						if remloc1>0 and remloc2==0 then affectp=chkc:IsControler(tp)
						elseif remloc1==0 and remloc2>0 then affectp=chkc:IsControler(1-tp)
						else chkcloc,affectp=true,true
						end
						return chkcloc and affectp and (not filter or filter(chkc,table.unpack(params))) 
					end
					if chk==0 then
						local check
						if funs[1] then 
							check=true
						else
							check=(Duel.GetLocationCount(p,LOCATION_SZONE)>0 and Duel.IsExistingTarget(filter,tp,remloc1,remloc2,remtotal,excep,table.unpack(params)))
						end
						return check and (not funs[4] or funs[4](e,tp,eg,ep,ev,re,r,rp))
					end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(filter),tp,remloc1,remloc2,remtotal,remtotmax,excep,table.unpack(params))
					if remloc1&LOCATION_GRAVE>0 or remloc2&LOCATION_GRAVE>0 then
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,remtotal,0,0)
					end
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if tplayer==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					if chk==0 then
						local check
						if funs[1] then 
							check=true
						else
							check=(Duel.GetLocationCount(p,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(filter,tp,remloc1,remloc2,remtotal,excep,table.unpack(params)))
						end
						return check and (not funs[4] or funs[4](e,tp,eg,ep,ev,re,r,rp))
					end
					local g=Duel.GetMatchingGroup(filter,tp,remloc1,remloc2,excep,table.unpack(params))
					if remloc1&LOCATION_GRAVE>0 then
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,remtotal,tp,LOCATION_GRAVE)
					end
					if remloc2&LOCATION_GRAVE>0 then
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,remtotal,1-tp,LOCATION_GRAVE)
					end
				end
	end
end
function cm.SetOperation(istargeting,tplayer,mode,remloc1,remloc2,remfilter,remtotal,...)
	--funs[1],[2],[3],[4]: target specifications, exception, max target number, BaitDollConfirmation, "andifyoudo" or "then", conjuncted effect, "also" effect
	local funs={...}
	local resolve=true
	local conj=false
	local excep=nil
	local remtotmax=funs[3]
	if not funs[3] then remtotmax=remtotal end
	local hint,categ=0,0
	if istargeting then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if tplayer==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp)
					else
						filter=remfilter
						params={}
					end
					local tc,tcheck,tgt=nil,nil,nil
					if remtotmax==1 then
						tc=Duel.GetFirstTarget()
						tcheck=(tc:IsRelateToEffect(e) and tc:IsSSetable() and (not funs[1] or funs[1](tc,e,tp)))
					else
						tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Glitchy.MultipleTargetsCheckSet,nil,e,funs[1],tp)
						tcheck=(#tc>0)
					end
					if tcheck then
						if tgt then tc=tgt end
						local _,set=Duel.SSet(tp,tc,p)
						if set>0 then
							Duel.ConfirmCards(1-tp,tc)
							conj=true
							if mode then
								if mode==0 then
									local tgroup=tc
									if remtotmax==1 then tgroup=Group.FromCards(tc) end
									local tgtc=tgroup:GetFirst()
									while tgtc do
										cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_CANNOT_TRIGGER,1)
										tgtc=tgroup:GetNext()
									end
								else
									local tgroup=tc
									if remtotmax==1 then tgroup=Group.FromCards(tc) end
									local tgtc=tgroup:GetFirst()
									while tgtc do
										if tgtc:IsType(TYPE_TRAP) then
											cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_TRAP_ACT_IN_SET_TURN,nil)
										elseif tgtc:IsType(TYPE_QUICKPLAY) then
											cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_QP_ACT_IN_SET_TURN,nil)
										end
										tgtc=tgroup:GetNext()
									end
								end
							end
						end
						if funs[5] and ((funs[5]=="andifyoudo" and conj) or (funs[5]=="then")) then
							funs[6](e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if funs[7] then
						funs[7](e,tp,eg,ep,ev,re,r,rp)
					end
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if tplayer==0 then p=tp else p=1-tp end
					local filter,params
					if type(remfilter(1))=="table" then
						filter,params=remfilter(0),remfilter(1)
						cm.ParamConverter(params,e,tp,eg,ep,ev,re,r,rp,chk)
					else
						filter=remfilter
						params={}
					end
					if funs[2] then excep=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,hint)
					local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(filter),tp,remloc1,remloc2,remtotal,remtotmax,excep,table.unpack(params))
					if g:GetCount()>0 then
						local ghint=g:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_DECK+LOCATION_EXTRA)
						Duel.HintSelection(ghint)
						local _,set=Duel.SSet(tp,g,p)
						if set>0 then
							Duel.ConfirmCards(1-tp,g)
							conj=true
							if mode then
								if mode==0 then
									local tgtc=g:GetFirst()
									while tgtc do
										cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_CANNOT_TRIGGER,1)
										tgtc=g:GetNext()
									end
								else
									local tgtc=g:GetFirst()
									while tgtc do
										if tgtc:IsType(TYPE_TRAP) then
											cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_TRAP_ACT_IN_SET_TURN,nil)
										elseif tgtc:IsType(TYPE_QUICKPLAY) then
											cm.SingleEffectGiver(e:GetHandler(),tgtc,EFFECT_QP_ACT_IN_SET_TURN,nil)
										end
										tgtc=g:GetNext()
									end
								end
							end
						end
						if funs[5] and ((funs[5]=="andifyoudo" and conj) or (funs[5]=="then")) then
							funs[6](e,tp,eg,ep,ev,re,r,rp)
						end
					end
					if funs[7] then
						funs[7](e,tp,eg,ep,ev,re,r,rp)
					end
				end
	end
end
------------------------------Equip Effects------------------------------
--MODIFY the EQUIPPED MONSTERS' STATS: Change ATK and/or DEF of the equipped monster
--Params: 1: c / 2: Specify the ATK value the monster will gain (put a negative value if you want the monster to lose ATK) / 3: Specify the DEF value the monster will gain (put a negative value if you want the monster to lose DEF)
-- funs[1]: See EquipEffectModule
function cm.EquipModifyATKDEF(c,atkval,defval,...)
	local funs={...}
	local cond=nil
	if funs[1] then
		cond=funs[1]
	end
	local e1,e2
	if atkval and atkval~=0 then
		e1=cm.EquipEffectModule(c,EFFECT_UPDATE_ATTACK,cond)
		e1:SetValue(atkval)
		c:RegisterEffect(e1)
	end
	if defval and defval~=0 then
		e2=cm.EquipEffectModule(c,EFFECT_UPDATE_DEFENSE,cond)
		e2:SetValue(defval)
		c:RegisterEffect(e2)
	end
	return e1,e2
end

------------------------------Field Effects------------------------------
--FORCE BATTLE POSITION: Monsters on the field are only allowed to stay in the determined position.
--Params: 1: c / 2: The position the monsters will take / 3: Disable option for the players to manually change the position (true/false)
-- 4, 5, 6, 7 and funs[1]: See FieldStatusEffectModule
--funs[2]: Condition
function cm.FieldForceBattlePosition(c,pos,lock,range,selfrange,opporange,target,...)
	local funs={...}
	local prop=nil
	if funs[1] then
		prop=funs[1]
	end
	local e1=cm.FieldStatusEffectModule(c,EFFECT_SET_POSITION,selfrange,opporange,target,prop)
	local e2
	if funs[2] then
		e1:SetCondition(funs[2])
	end
	e1:SetValue(pos)
	c:RegisterEffect(e1)
	if lock then
		e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		c:RegisterEffect(e2)
	end
	return e1,e2
end
--MODIFY MONSTERS' STATS: Change the ATK and/or DEF ot specific monsters while this card is in the correct location
--Params: 1: c / 2: Specify the ATK value the monsters will gain (put a negative value if you want the monster to lose ATK) / 3: Specify the DEF value the monsters will gain (put a negative value if you want the monster to lose DEF)
-- funs[1]: See FieldStatusEffectModule
function cm.FieldModifyATKDEF(c,atkval,defval,range,selfrange,opporange,target,...)
	local funs={...}
	local prop=nil
	if funs[1] then
		prop=funs[1]
	end
	local e1,e2
	if atkval and atkval~=0 then
		e1=cm.FieldStatusEffectModule(c,EFFECT_UPDATE_ATTACK,range,selfrange,opporange,target,prop)
		if funs[2] then
			e1:SetCondition(funs[2])
		end
		e1:SetValue(atkval)
		c:RegisterEffect(e1)
	end
	if defval and defval~=0 then
		e2=cm.FieldStatusEffectModule(c,EFFECT_UPDATE_DEFENSE,range,selfrange,opporange,target,prop)
		if funs[2] then
			e2:SetCondition(funs[2])
		end
		e2:SetValue(defval)
		c:RegisterEffect(e2)
	end
	return e1,e2
end
--PREVENT ATTACKS
function cm.FieldPreventAttacks(c,range,selfrange,opporange,target,...)
	local funs={...}
	local prop,cond=funs[1],funs[2]
	local e1=cm.FieldStatusEffectModule(c,EFFECT_CANNOT_ATTACK_ANNOUNCE,range,selfrange,opporange,target,prop,cond)
	c:RegisterEffect(e1)
	return e1
end
------------------------------Flip Effects------------------------------
--CARD REMOVAL WHEN FLIPPED: Remove (destroy,banish,bounce...) a card(s) from a specified location when flipped face-up
-- funs[1],[2],[3],[4],[5],[6],[7] : Properties, Categories, Condition, Cost, Enable Exception, Additional Target conds, Target specs, BaitDollConfirmation, Enable Hopt, Enable OATH
function cm.FlipRemoval(c,remtype,forced,istargeting,remloc1,remloc2,remfilter,remtotal,remtotmax,...)
	local funs={...}
	local prop,selfrange,opporange=0,0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	local etyp
	if forced==true then
		etyp="forced flip"
	else
		etyp="optional flip"
		prop=prop+EFFECT_FLAG_DELAY
	end
	if istargeting then prop=prop+EFFECT_FLAG_CARD_TARGET end
	if remloc1 then selfrange=remloc1 end
	if remloc2 then opporange=remloc2 end
	local target=cm.RemovalTarget(istargeting,remtype,selfrange,opporange,remfilter,remtotal,forced,exc,remtotmax,funs[6])
	local operation=cm.RemovalOperation(istargeting,remtype,selfrange,opporange,remfilter,remtotal,funs[7],exc,remtotmax,funs[8])
	local e1=cm.SingleEffectModule(c,etyp,nil,nil,target,operation,funs[2],prop,funs[3],funs[4],funs[9],funs[10])
	c:RegisterEffect(e1)
	return e1
end
------------------------------Fusion EFFECTS------------------------------
--FUSION SUMMON
-- funs[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] : Properties, Categories, Condition, Cost, Enable Exception, Enable Hopt, Enable OATH, precheck, presummon ops, conjuncted effects
function cm.FusionSummonModule(c,event,typ,range,polytype,fusfilter,matfilter,selfmat,oppomat,cinfo,include,fcheck,gcheck,altcon,altmatself,altmatoppo,proc,procmat,procoppo,procfusion,...)
	local funs={...}
	local categ,prop=0,0
	local exc=funs[5]
	if not funs[5] then exc=false end
	if funs[1] then
		prop=funs[1]
	end
	if funs[2] then
		categ=categ|(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	end
	local target=cm.FusionTarget(polytype,fusfilter,matfilter,selfmat,oppomat,cinfo,include,fcheck,gcheck,altcon,altmatself,altmatoppo,proc,procmat,procoppo,procfusion)
	local operation=cm.FusionOperation(polytype,fusfilter,matfilter,selfmat,oppomat,include,fcheck,gcheck,altcon,altmatself,altmatoppo,proc,procmat,procoppo,procfusion,funs[8],funs[9],funs[10])
	local e1=cm.ActivateModule(c,event,typ,target,operation,funs[2],prop,range,funs[3],funs[4],funs[6],funs[7])
	c:RegisterEffect(e1)
	return e1
end
--Fusion Type: POLYMERIZATION = Fusion Summons by sending monsters from your hand and/or field to the GY
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonPoly(c,event,typ,range,fusfilter,matfilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,nil,nil,nil,include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: OVERLOAD = Fusion Summons by banishing monsters from your field and/or GY
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonOverload(c,event,typ,range,fusfilter,matfilter,overloadfilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"banish",fusfilter,matfilter,{[LOCATION_GRAVE]=overloadfilter},nil,{[CATEGORY_REMOVE]=LOCATION_ONFIELD+LOCATION_GRAVE},include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: POLYDECK / OVERLOADDECK = Fusion Summons by sending to the GY/banishing monsters from your hand, field and also Deck
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonPolyDeck(c,event,typ,range,fusfilter,matfilter,efilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,{[LOCATION_DECK]=efilter},nil,nil,include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
function cm.FusionSummonOverloadDeck(c,event,typ,range,fusfilter,matfilter,efilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"banish",fusfilter,matfilter,{[LOCATION_DECK]=efilter},nil,{[CATEGORY_REMOVE]=LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK},include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: SUPERPOLY = Fusion Summons by sendind monsters from either field to the GY
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonSuperpoly(c,event,typ,range,fusfilter,matfilter,efilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,nil,{[LOCATION_MZONE]=efilter},nil,include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: SHUFFLE = Fusion Summons by shuffling monsters from your GY or that are banished
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonShuffle(c,event,typ,range,fusfilter,efilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"spin",fusfilter,nil,{[LOCATION_GRAVE+LOCATION_REMOVED]=efilter},nil,{[CATEGORY_TODECK]=LOCATION_REMOVED+LOCATION_GRAVE},include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: VOIDIMAGINATION = Regular Poly, but when the condition is met you can Fusion Summon by sending up to X monsters from a location to the GY
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, precheck, presummon ops, conjuncted effects
function cm.FusionSummonVoidImagination(c,event,typ,range,fusfilter,matfilter,include,altcon,altmatself,altmatoppo,fcheckloc,fcheckct,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10]
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,nil,nil,nil,include,{"upto",fcheckloc,fcheckct},{"upto",fcheckloc,fcheckct},altcon,altmatself,altmatoppo,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: SHADDOLL = Regular Poly, but when the condition is met you can Fusion Summon by using monsters from another location
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, precheck, presummon ops, conjuncted effects
function cm.FusionSummonShaddoll(c,event,typ,range,fusfilter,matfilter,include,altcon,altmatself,altmatoppo,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,nil,nil,nil,include,fcheck,gcheck,altcon,altmatself,altmatoppo,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: BORREL = Fusion Summons by destroying monsters in your hand and/or field
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonBorrel(c,event,typ,range,fusfilter,matfilter,include,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local e1=cm.FusionSummonModule(c,event,typ,range,"destroy",fusfilter,matfilter,nil,nil,{[CATEGORY_DESTROY]=LOCATION_ONFIELD+LOCATION_HAND},include,fcheck,gcheck,nil,nil,nil,nil,nil,nil,nil,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end
--Fusion Type: IFYOUWOULDSUMMON = Regular Poly, but if you would summon a certain Fusion Monster you can use another procedure
-- funs[...] : Properties, Categories, Condition, Cost, Enable Exception, Enable Count Limit, Enable OATH, fcheckadditional, gcheckadditional, precheck, presummon ops, conjuncted effects
function cm.FusionSummonIfYouWouldSummon(c,event,typ,range,fusfilter,matfilter,include,procfusion,proc,procmat,procmat_o,...)
	local funs={...}
	local prop,categ,cond,cost,exc,ctlim,oath,fcheck,gcheck,precheck,presum,conj=funs[1],funs[2],funs[3],funs[4],funs[5],funs[6],funs[7],funs[8],funs[9],funs[10],funs[11],funs[12]
	local cinfo,loc1,loc2,cat,cat2=nil,0,0,0,0
	if procmat then
		for k,v in pairs(procmat) do
			local fixloc=loc1&k
			loc1=loc1+k-fixloc
		end
	end
	if procmat_o then
		for k,v in pairs(procmat_o) do
			local fixloc=loc2&k
			loc2=loc2+k-fixloc
		end
	end
	if (proc=="banish" or proc=="banishfacedown") then cat=CATEGORY_REMOVE cat2=CATEGORY_REMOVE
	elseif proc=="spin" then cat=CATEGORY_TODECK cat2=CATEGORY_TODECK
	elseif proc=="destroy" then cat=CATEGORY_DESTROY cat2=CATEGORY_DESTROY
	end
	if cat~=0 then
		cinfo={[cat]=loc1;[cat2]=loc2}
	end
	local e1=cm.FusionSummonModule(c,event,typ,range,"standard",fusfilter,matfilter,nil,nil,cinfo,include,fcheck,gcheck,nil,nil,nil,proc,procmat,procmat_o,procfusion,prop,categ,cond,cost,exc,ctlim,oath,precheck,presum,conj)
	return e1
end

--Effect Modifiers
function cm.SelfDestroyCountdown(effect,range,phase,tplayer,turn,...)
	--Once the effect is used, a countdown is triggered and at the end of it the card self-destroys (see Swords of Revealing Lights)
	-- [1]: Extra Cond for selfdestruction / Extra Operation after selfdestruction
	local funs={...}
	local cond,eop=funs[1],funs[2]
	local tg=effect:GetTarget()
	local p=0
	if tplayer then
		if tplayer==0 then p=RESET_SELF_TURN
		else p=RESET_OPPO_TURN
		end
	end
	if not tg then
		effect:SetTarget(function (e,tp,eg,ep,ev,re,r,rp,chk)
							if chk==0 then return true end
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e1:SetCode(EVENT_PHASE+phase)
							e1:SetCountLimit(1)
							e1:SetRange(range)
							e1:SetCondition(function (e,tp,eg,ep,ev,re,r,rp)
												local turnp=0
												if tplayer==0 then turnp=tp else turnp=1-tp end
												return Duel.GetTurnPlayer()==turnp and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
											end)
							e1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
												local c=e:GetHandler()
												local ct=c:GetTurnCounter()
												ct=ct+1
												c:SetTurnCounter(ct)
												if ct==turn then
													Duel.Destroy(c,REASON_RULE)
													c:ResetFlagEffect(1082946)
													if eop then
														eop(e,tp,eg,ep,ev,re,r,rp)
													end
												end
											end)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+phase+p,turn)
							e:GetHandler():RegisterEffect(e1)
							e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+phase+p,0,turn)
						end)
	else
		effect:SetTarget(function (e,tp,eg,ep,ev,re,r,rp,chk)
							if chk==0 then return tg(e,tp,eg,ep,ev,re,r,rp,0) end
							tg(e,tp,eg,ep,ev,re,r,rp,1)
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e1:SetCode(EVENT_PHASE+phase)
							e1:SetCountLimit(1)
							e1:SetRange(range)
							e1:SetCondition(function (e,tp,eg,ep,ev,re,r,rp)
												local turnp=0
												if tplayer==0 then turnp=tp else turnp=1-tp end
												return Duel.GetTurnPlayer()==turnp and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
											end)
							e1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
												local c=e:GetHandler()
												local ct=c:GetTurnCounter()
												ct=ct+1
												c:SetTurnCounter(ct)
												if ct==turn then
													Duel.Destroy(c,REASON_RULE)
													c:ResetFlagEffect(1082946)
													if eop then
														eop(e,tp,eg,ep,ev,re,r,rp)
													end
												end
											end)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+phase+p,turn)
							e:GetHandler():RegisterEffect(e1)
							e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+phase+p,0,turn)
						end)
	end
end