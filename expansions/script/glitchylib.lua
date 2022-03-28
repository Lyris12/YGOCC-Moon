Single, Field = {}, {}
sng, fld = Single, Field

--New ACTIONS
ACTION_DESTROY		=	1
ACTION_BANISH		=	2
ACTION_BANISH_FD	=	3
ACTION_TOHAND		=	4
ACTION_TOGRAVE		=	5
ACTION_TODECK		=	6
ACTION_TOEXTRA		=	7

--New EFFECTS
EFFECT_CANNOT_ACTIVATE_LMARKER=8000
EFFECT_CANNOT_DEACTIVATE_LMARKER=8001
EFFECT_PRE_LOCATION=8002
EFFECT_NO_ARCHETYPE=8003
EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL 	= 8004
EFFECT_GLITCHY_EXTRA_LINK_MATERIAL	    = 8005
EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG		= 8006
EFFECT_GLITCHY_HACK_CODE 				= 8007
EFFECT_NAME_DECLARED					= 8008
EFFECT_GLITCHY_CANNOT_DISABLE			= 8009

EFFECT_BECOME_HOPT=99977755
EFFECT_SYNCHRO_MATERIAL_EXTRA=26134837
EFFECT_SYNCHRO_MATERIAL_MULTIPLE=26134838
EFFECT_REVERSE_WHEN_IF=48928491

--constants aliases
TYPE_ST			= TYPE_SPELL+TYPE_TRAP

ARCHE_FUSION	= 0x46

RESET_TURN_SELF = RESET_SELF_TURN
RESET_TURN_OPPO = RESET_OPPO_TURN

-----------------------------------------------------------------------
-------------------------------NEGATES---------------------------------
local _IsChainDisablable, _NegateEffect = Duel.IsChainDisablable, Duel.NegateEffect

Duel.IsChainDisablable = function(ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	if te and aux.GetValueType(te:GetHandler())=="Card" and te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE) then
		local egroup={te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local val=ce:GetValue()
				if not val or type(val)=="number" or val(ce,self_reference_effect) then
					return false
				end
			end
		end
	end
	return _IsChainDisablable(ct)
end
Duel.NegateEffect = function(ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	if te and aux.GetValueType(te:GetHandler())=="Card" and te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE) then
		local egroup={te:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local val=ce:GetValue()
				if not val or type(val)=="number" or val(ce,self_reference_effect) then
					return false
				end
			end
		end
	end
	return _NegateEffect(ct)
end

function Auxiliary.GlitchyCannotDisableCon(f)
	return	function(e)
				local egroup={e:GetHandler():IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
				for _,ce in ipairs(egroup) do
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or type(val)=="number" or val(ce,e) then
							return false
						end
					end
				end
				return not f or f(e)
			end
end
function Auxiliary.GlitchyCannotDisable(f)
	return	function(e,c)
				local egroup={c:IsHasEffect(EFFECT_GLITCHY_CANNOT_DISABLE)}
				for _,ce in ipairs(egroup) do	
					if ce and ce.GetLabel then
						local val=ce:GetValue()
						if not val or type(val)=="number" or val(ce,e) then
							return false
						end
					end
				end
				return not f or f(e,c)
			end
end

-----------------------------------------------------------------------
-------------------------------SELECTION-------------------------------
function Duel.IsExisting(target,f,loc1,loc2,min,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.IsExistingTarget or Duel.IsExistingMatchingCard
	
	return func(f,tp,loc1,loc2,min,nil,...)
end

function Duel.Select(target,hint,f,loc1,loc2,min,max,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,tp,loc1,loc2,min,max,nil,...)
	return g
end

------------------------------------------------------------------------
------------------------CARD OPERATION FUNCTIONS------------------------
function Auxiliary.BanishFilter(f,r,actp,pos)
	if not r or r==REASON_EFFECT then
		return	function(c,...)
					return (not f or f(c,...)) and c:IsAbleToRemove(actp,pos)
				end
	else
		return	function(c,...)
					return (not f or f(c,...)) and c:IsAbleToRemoveAsCost(pos)
				end
	end
end
function Auxiliary.DiscardFilter(f,r)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsDiscardable(r)
			end
end
function Auxiliary.SearchFilter(f,r)
	local check=(not r or r==REASON_EFFECT) and Card.IsAbleToHand or Card.IsAbleToHandAsCost
	return	function(c,...)
				return (not f or f(c,...)) and check(c)
			end
end
function Auxiliary.SettingFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsSSetable()
			end
end
function Auxiliary.SPSummonFilter(f,e,sumtype,sump,ign1,ign2,pos)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos)
			end
end

function Auxiliary.ActionCategory(act)
	local t={[1]=CATEGORY_DESTROY, [2]=CATEGORY_REMOVE, [3]=CATEGORY_REMOVE, [4]=CATEGORY_TOHAND, [5]=CATEGORY_TOGRAVE, [6]=CATEGORY_TODECK, [7]=CATEGORY_TOEXTRA}
	return t[act]
end

function Duel.Search(g,tp)
	local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	return ct
end
function Duel.Negate(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e2)
	if tc:IsType(TYPE_TRAPMONSTER) then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
		tc:RegisterEffect(e3)
	end
	return e1,e2
end

--Special Summons
function Auxiliary.SpecialSummonButBanish(c,e,tp,loc)
	if not loc then loc=LOCATION_REMOVED end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(loc)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

-----------------------------------------------------------------------------
-------------------------------PASSIVE EFFECTS-------------------------------
function Effect.Single(c,code,val,range,prop,m)
	if not prop then prop=0 end
	if range then prop=prop|EFFECT_FLAG_SINGLE_RANGE end
	local etyp=(not m or m==0) and EFFECT_TYPE_SINGLE or (m==1) and EFFECT_TYPE_EQUIP or EFFECT_TYPE_XMATERIAL
	
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(code)
	e:SetValue(val)
	if prop then
		e:SetProperty(prop)
	end
	if range then
		e:SetRange(range)
	end
	c:RegisterEffect(e)
	return e
end
function Effect.Field(c,code,val,range,loc1,loc2,tg,prop)
	if not prop then prop=0 end
	
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(code)
	e:SetValue(val)
	e:SetRange(range)
	e:SetTargetRange(loc1,loc2)
	if tg then
		e:SetTarget(tg)
	end
	if prop then
		e:SetProperty(prop)
	end
	c:RegisterEffect(e)
	return e
end
function Effect.PlayerField(c,code,val,range,p1,p2,prop)
	if p1 then p1=1 else p1=0 end
	if p2 then p2=1 else p2=0 end
	if prop&EFFECT_FLAG_PLAYER_TARGET==0 then prop=prop|EFFECT_FLAG_PLAYER_TARGET end

	return Effect.Field(c,code,val,range,p1,p2,prop)
end

--Update ATK/DEF of the card
function Single.UpdateStats(c,m,atk,def)
	local range=(not m or m==0) and LOCATION_MZONE or nil
	local e1,e2
	if atk then
		e1=Effect.Single(c,EFFECT_UPDATE_ATTACK,atk,range,0,m)
	end
	if def then
		e2=Effect.Single(c,EFFECT_UPDATE_DEFENSE,def,range,0,m)
	end
	return e1,e2
end
function Field.UpdateStats(c,range,loc1,loc2,tg,atk,def)
	local e1,e2
	if atk then
		e1=Effect.Field(c,EFFECT_UPDATE_ATTACK,atk,range,loc1,loc2,tg)
	end
	if def then
		e2=Effect.Field(c,EFFECT_UPDATE_DEFENSE,def,range,loc1,loc2,tg)
	end
	return e1,e2
end

----------------------------------------------------------------------------------
-------------------------------CARD REMOVAL EFFECTS-------------------------------
function Effect.Trigger(e,forced,miss_timing,code)
	local etyp=(forced) and EFFECT_TYPE_TRIGGER_F or EFFECT_TYPE_TRIGGER_O
	e:SetType(EFFECT_TYPE_SINGLE+etyp)
	if not miss_timing then
		e:SetProperty(EFFECT_FLAG_DELAY)
	end
	e:SetCode(code)
end
--CONDITION

--When this card is used as material for the (reason) Summon of (f)
function Auxiliary.UsedAsMaterialCond(reason,f)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return (not reason or r&reason>0) and (not f or f(e:GetHandler():GetReasonCard(),e,tp))
			end
end
function Effect.UsedAsMaterial(e,forced,miss_timing,reason,f)
	e:Trigger(forced,miss_timing,EVENT_BE_MATERIAL)
	e:SetCondition(aux.UsedAsMaterialCond(reason,f))
end

--When this card is X Summoned
function Auxiliary.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Auxiliary.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Auxiliary.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Auxiliary.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

------------------------------------------
------------------COSTS-------------------

--Discard a card(s) as cost
function Auxiliary.DiscardCost(f,min,max,...)
	local extras={...}
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(aux.DiscardFilter(f,REASON_COST),tp,LOCATION_HAND,0,1,nil) end
				Duel.DiscardHand(tp,aux.DiscardFilter(f,REASON_COST),1,1,REASON_COST+REASON_DISCARD)
			end
end
--Discards itself as cost
function Auxiliary.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

--Shuffles itself to ED as cost
function Auxiliary.ToExtraSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--TARGETS
function Auxiliary.SimpleTarget(f,loc1,loc2,min,info)
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,nil,e,tp) end
				if info then
					info()
				end
			end
end
function Auxiliary.SettingTarget(f,loc1,loc2,min)
	return aux.SimpleTarget(aux.SettingFilter(f),loc1,loc2,min)
end

--OPERATIONS
function Auxiliary.SimpleOp(f,loc1,loc2,min,max,hint,action,fizzle)
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if fizzle and not e:GetHandler():IsRelateToEffect(e) then return end
				Duel.Hint(HINT_SELECTMSG,tp,hint)
				local sg=Duel.SelectMatchingCard(tp,aux.SettingFilter(f),tp,loc1,loc2,min,max,nil,e,tp)
				if #sg>0 then
					return action(sg,e,tp)
				end
			end
end
function Auxiliary.SettingOp(f,loc1,loc2,min,max,fizzle)
	return aux.SimpleOp(aux.SettingFilter(f),loc1,loc2,min,max,HINTMSG_SET,function(sg,e,tp) return Duel.SSet(tp,sg) end,fizzle)
end

--RESTRICTIONS
--Scripts: You cannot Special Summon monsters the turn you use (activate, if act is TRUE) this effect, except (f) monsters.
function Auxiliary.SPSummonRestr(act,f)
	local prop=EFFECT_FLAG_PLAYER_TARGET
	if act then prop=EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.GetCustomActivityCount(e:GetHandler():GetOriginalCode(),tp,ACTIVITY_SPSUMMON)==0 end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(prop)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetTargetRange(1,0)
				e1:SetTarget(aux.TargetBoolFunction(aux.NOT(f)))
				Duel.RegisterEffect(e1,tp)
			end
end

--ACTION COUNTERS
--Counts the number of Special Summons executed during the turn, ignoring the cards that match the counterfilter
function Card.SPSummonCounter(c,f)
	return Duel.AddCustomActivityCounter(c:GetOriginalCode(),ACTIVITY_SPSUMMON,f)
end

--FULL-PACKAGE EFFECTS
function Effect.SetSpellTrap(e,f,loc1,loc2,min,max,fizzle)
	e:SetTarget(aux.SettingTarget(f,loc1,loc2,min))
	e:SetOperation(aux.SettingOp(f,loc1,loc2,min,max,fizzle))
end

--Modified Functions: Names
local _IsCode, _IsFusionCode, _IsLinkCode, _IsOriginalCodeRule =
Card.IsCode, Card.IsFusionCode, Card.IsLinkCode, Card.IsOriginalCodeRule

Card.IsCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsCode(c,table.unpack(hacked_codes))
	else
		return _IsCode(c,code,...)
	end
end
Card.IsFusionCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsFusionCode(c,table.unpack(hacked_codes))
	else
		return _IsFusionCode(c,code,...)
	end
end
Card.IsLinkCode = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsLinkCode(c,table.unpack(hacked_codes))
	else
		return _IsLinkCode(c,code,...)
	end
end
Card.IsOriginalCodeRule = function(c,code,...)
	local x={...}
	if c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE) then
		local hacked_codes={}
		for _,e in ipairs({c:IsHasEffect(EFFECT_GLITCHY_HACK_CODE)}) do
			local val=e:GetValue()
			local re=e:GetLabelObject()
			if val and (not re or re and self_reference_effect and self_reference_effect==re) then
				table.insert(hacked_codes,val)
			end
		end
		return _IsOriginalCodeRule(c,table.unpack(hacked_codes))
	else
		return _IsOriginalCodeRule(c,code,...)
	end
end

--Modified Functions: ANNOUNCES
local _AnnounceCard =
Duel.AnnounceCard

Duel.AnnounceCard = function(p,...)
	local ac=_AnnounceCard(p,...)
	local e=self_reference_effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_NAME_DECLARED)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,ac))
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetValue(ac)
	Duel.RegisterEffect(e1,p)
	return ac
end

--Modified Functions: FUSIONS
function Auxiliary.PureExtraFilter(c)
	return c:GetFlagEffect(1005)>0
end
function Auxiliary.PureExtraFilterLoop(c,eff)
	return c:GetFlagEffect(1005)>0 and not c:IsHasEffect(eff)
end
function Auxiliary.ExtraFusionFilter0(c,ce,tg)
	return c:IsCanBeFusionMaterial() and tg(ce,c)
end
function Auxiliary.ExtraFusionFilter(c,e,ce,tg)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) and tg(ce,c)
end
function Auxiliary.ExtraMaterialFilterSelect(c,e,f)
	return c:GetFlagEffect(1006)>0 and f(e,c)
end
function Auxiliary.ExtraMaterialFilterGoal(mg,og)
	local og=og:Clone()
	local res = (not og:IsExists(aux.TRUE,1,mg) or not og:IsExists(aux.PureExtraFilter,1,mg))
	og:DeleteGroup()
	return res
end
function Auxiliary.ExtraMaterialMaxCheck(c,id)
	if not c:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG) then return false end
	local res=false
	for _,flag in ipairs({c:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
		if flag and flag.GetLabel then
			if flag:GetValue()==id then
				res=true
			else
				return false
			end
		end
	end
	return res
end

local _GetFusionMaterial, _CheckFusionMaterial, _SelectFusionMaterial, _FCheckMixGoal, _SendtoGrave, _Remove, _SendtoDeck, _Destroy, _SendtoHand =
Duel.GetFusionMaterial, Card.CheckFusionMaterial, Duel.SelectFusionMaterial, Auxiliary.FCheckMixGoal, Duel.SendtoGrave, Duel.Remove, Duel.SendtoDeck, Duel.Destroy, Duel.SendtoHand

Duel.GetFusionMaterial = function(tp,...)
	local x={...}
	local loc = #x>0 and x[1] or LOCATION_MZONE+LOCATION_HAND
	local res,base=_GetFusionMaterial(tp,...)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
		local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
		local ogres=res:Clone()
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget())
				if #mats>0 then
					for tc in aux.Next(mats) do
						if tc:GetFlagEffect(1005)>0 then
							tc:ResetFlagEffect(1005)
						end
						if not ogres:IsContains(tc) then
							tc:RegisterFlagEffect(1005,RESET_CHAIN,0,1)
						end
					end
					res:Merge(mats)
				end
			end
		end
	end
	return res,base
end

Card.CheckFusionMaterial = function(c,...)
	local x={...}
	local matg = #x>0 and x[1] or nil
	local cg = #x>1 and x[2] or nil
	local chkf = #x>2 and x[3] or PLAYER_NONE
	local not_material = #x>3 and x[4]
	
	local res=_CheckFusionMaterial(c,matg,cg,chkf,not_material)
	if self_reference_effect then
		local tp=self_reference_effect:GetHandlerPlayer()
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
			local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
			local all_mats=Group.CreateGroup()
			for _,ce in ipairs(egroup) do
				if ce and ce.GetLabel then
					local id=ce:GetLabel()
					local chk_fus=ce:GetValue()
					if aux.GetValueType(chk_fus)=="function" then
						chk_fus,_=chk_fus(ce,c,tp)
					end
					if chk_fus then
						local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget())
						if #mats>0 then
							for ec1 in aux.Next(mats) do
								if ec1:GetFlagEffect(1005)>0 then
									if ec1:GetFlagEffect(1006)<=0 then
										ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
									end
									local flag=Effect.CreateEffect(ce:GetHandler())
									flag:SetType(EFFECT_TYPE_SINGLE)
									flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
									flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
									flag:SetValue(id)
									flag:SetReset(RESET_CHAIN)
									ec1:RegisterEffect(flag)
								end
							end
							all_mats:Merge(mats)
						end
					end
				end
			end
			all_mats:Merge(matg)
			res=_CheckFusionMaterial(c,all_mats,cg,chkf,not_material)
			for ec2 in aux.Next(all_mats) do
				if ec2:GetFlagEffect(1006)>0 then
					ec2:ResetFlagEffect(1006)
				end
				for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
					if flag and flag.GetLabel then
						flag:Reset()
					end
				end
			end
		end
	end
	return res
end

Duel.SelectFusionMaterial = function(tp,fc,matg,...)
	local x={...}
	local cg= #x>0 and x[1] or nil
	local chkf= #x>1 and x[2] or PLAYER_NONE
	local not_material= #x>2 and x[3]
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
		return _SelectFusionMaterial(tp,fc,matg,cg,chkf,not_material)
	else
		local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}
		local all_mats=Group.CreateGroup()
		for _,ce in ipairs(egroup) do
			if ce and ce.GetLabel then
				local id=ce:GetLabel()
				local chk_fus=ce:GetValue()
				if aux.GetValueType(chk_fus)=="function" then
					chk_fus,_=chk_fus(ce,fc,tp)
				end
				if chk_fus then
					local mats=Duel.GetMatchingGroup(aux.ExtraFusionFilter,tp,0xff,0xff,nil,self_reference_effect,ce,ce:GetTarget())
					if #mats>0 then
						for ec1 in aux.Next(mats) do
							if ec1:GetFlagEffect(1005)>0 then
								if ec1:GetFlagEffect(1006)<=0 then
									ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
								end
								local flag=Effect.CreateEffect(ce:GetHandler())
								flag:SetType(EFFECT_TYPE_SINGLE)
								flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
								flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
								flag:SetValue(id)
								flag:SetReset(RESET_CHAIN)
								ec1:RegisterEffect(flag)
							end
						end
						all_mats:Merge(mats)
					end
				end
			end
		end
		all_mats:Merge(matg)
		
		local chosen_mats=_SelectFusionMaterial(tp,fc,all_mats,cg,chkf,not_material)
		for ec2 in aux.Next(all_mats) do
			if ec2:GetFlagEffect(1006)>0 then
				ec2:ResetFlagEffect(1006)
			end
			for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
				if flag and flag.GetLabel then
					flag:Reset()
				end
			end
		end
		
		local extra_mats=Group.CreateGroup()
		local valid_effs,extra_opt={},{}
		for mc in aux.Next(chosen_mats) do
			for _,ce in ipairs(egroup) do
				if --[[mc:GetFlagEffect(1005)>0 and ]]ce and ce.GetLabel and ce:GetTarget()(ce,mc) then
					--register card as possible extra material
					extra_mats:AddCard(mc)
					mc:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
					--register description
					local d=ce:GetDescription()
					for _,desc in ipairs(extra_opt) do
						if desc==d then
							d=false
							break
						end
					end
					if d then
						table.insert(extra_opt,d)
						table.insert(valid_effs,ce)
					end
				end
			end
		end
		if #extra_opt>0 and (chosen_mats:IsExists(aux.PureExtraFilter,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) then
			local ecount=0
			while aux.GetValueType(extra_mats)=="Group" and #extra_mats>0 and #extra_opt>0 and (ecount==0 or chosen_mats:IsExists(aux.PureExtraFilterLoop,1,nil,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) do
				local opt=Duel.SelectOption(tp,table.unpack(extra_opt))+1
				local eff=valid_effs[opt]
				local _,max=eff:GetValue()(eff,nil)
				if not max or max==0 then max=#extra_mats end
				local emats=extra_mats:SelectSubGroup(tp,aux.ExtraMaterialFilterGoal,false,1,max,extra_mats)
				--local emats=extra_mats:FilterSelect(tp,aux.ExtraMaterialFilterSelect,1,max,nil,eff,eff:GetTarget())
				if #emats>0 then
					for tc in aux.Next(emats) do
						local e1=Effect.CreateEffect(tc)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
						e1:SetOperation(eff:GetOperation())
						e1:SetLabel(ecount)
						e1:SetReset(RESET_CHAIN)
						tc:RegisterEffect(e1,true)
						extra_mats:RemoveCard(tc)
					end
				end
				table.remove(extra_opt,opt)
				table.remove(valid_effs,opt)
				ecount=ecount+1
			end
		end
		for ec3 in aux.Next(matg) do
			if ec3:GetFlagEffect(1005)>0 then
				ec3:ResetFlagEffect(1005)
			end
		end
		for ec4 in aux.Next(chosen_mats) do
			if ec4:GetFlagEffect(1006)>0 and not ec4:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL) then
				ec4:ResetFlagEffect(1006)
			end
		end
		return chosen_mats
	end
end

Auxiliary.FCheckMixGoal = function(sg,tp,fc,sub,chkfnf,...)
	for _,e in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)}) do
		local id=e:GetLabel()
		local val=e:GetValue()
		if val then
			local _,valmax=val(e,nil)
			if not (not sg or not sg:IsExists(aux.ExtraMaterialMaxCheck,valmax+1,nil,id)) then
				return false
			end
		end
	end
	return _FCheckMixGoal(sg,tp,fc,sub,chkfnf,...)
end

Duel.SendtoGrave = function(tg,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoGrave(tg,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoGrave(rg,reason)
	local ct2=0
	
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.Remove = function(tg,pos,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Remove(tg,pos,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_Remove(rg,pos,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.SendtoDeck = function(tg,p,seq,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoDeck(tg,p,seq,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoDeck(rg,p,seq,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.Destroy = function(tg,reason,...)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _Destroy(tg,reason,...)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_Destroy(rg,reason,...)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end
Duel.SendtoHand = function(tg,p,reason)
	if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
		return _SendtoHand(tg,p,reason)
	end
	local rg=tg:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
	tg:Sub(rg)
	local opt=0
	local ct1=_SendtoHand(rg,p,reason)
	local ct2=0
	local ecount=0
	while #tg>0 do
		local extra_g=Group.CreateGroup()
		local extra_op=false
		for tc in aux.Next(tg) do
			local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
			if ce and ce.GetLabel and ce:GetLabel()==ecount then
				extra_g:AddCard(tc)
				if not extra_op then
					extra_op=ce:GetOperation()
				end
			end
		end
		if #extra_g>0 then
			tg:Sub(extra_g)
			for tc in aux.Next(extra_g) do
				tc:ResetFlagEffect(1006)
			end
			local extra_ct=extra_op(extra_g)
			ct2=ct2+extra_ct
		end
		ecount=ecount+1
	end
	return ct1+ct2
end

--Modified Functions: LINKS
function Auxiliary.ExtraLinkFilter0(c,ce,tg,lc)
	return c:IsCanBeLinkMaterial(lc) and tg(ce,c)
end

local _LinkCondition, _LinkTarget, _LinkOperation, _LCheckGoal =
Auxiliary.LinkCondition, Auxiliary.LinkTarget, Auxiliary.LinkOperation, Auxiliary.LCheckGoal

Auxiliary.LinkCondition = function(f,minc,maxc,gf)
	return	function(e,c,og,lmat,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_LMATERIAL)
				if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				
				if Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					local all_mats=Group.CreateGroup()
					for _,ce in ipairs(egroup) do
						if ce and ce.GetLabel then
							local id=ce:GetLabel()
							local chk_lnk=ce:GetValue()
							if aux.GetValueType(chk_lnk)=="function" then
								chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							end
							if chk_lnk then
								local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								if #mats>0 then
									for ec1 in aux.Next(mats) do
										if not mg:IsContains(ec1) then
											if ec1:GetFlagEffect(1006)<=0 then
												ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											end
											local flag=Effect.CreateEffect(ce:GetHandler())
											flag:SetType(EFFECT_TYPE_SINGLE)
											flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											flag:SetValue(id)
											flag:SetReset(RESET_CHAIN)
											ec1:RegisterEffect(flag)
										end
									end
									all_mats:Merge(mats)
								end
							end
						end
					end
					all_mats:Merge(mg)
					local res=all_mats:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
					for ec2 in aux.Next(all_mats) do
						if ec2:GetFlagEffect(1006)>0 then
							ec2:ResetFlagEffect(1006)
						end
						for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							if flag and flag.GetLabel then
								flag:Reset()
							end
						end
					end
					return res
				else			
					return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
				end
			end
end

Auxiliary.LinkTarget = function(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c,e)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				local fg=Auxiliary.GetMustMaterialGroup(tp,EFFECT_MUST_BE_LMATERIAL)
				Duel.SetSelectedCard(fg)
				
				if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local cancel=Duel.IsSummonCancelable()
					local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					if sg then
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					else
						return false
					end
				else
					local egroup={Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}
					local all_mats=Group.CreateGroup()
					for _,ce in ipairs(egroup) do
						if ce and ce.GetLabel then
							local id=ce:GetLabel()
							local chk_lnk=ce:GetValue()
							if aux.GetValueType(chk_lnk)=="function" then
								chk_lnk=chk_lnk(ce,c,mg,nil,tp)
							end
							if chk_lnk then
								local mats=Duel.GetMatchingGroup(aux.ExtraLinkFilter0,tp,0xff,0xff,nil,ce,ce:GetTarget(),c)
								if #mats>0 then
									for ec1 in aux.Next(mats) do
										if not mg:IsContains(ec1) then
											if ec1:GetFlagEffect(1006)<=0 then
												ec1:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
											end
											local flag=Effect.CreateEffect(ce:GetHandler())
											flag:SetType(EFFECT_TYPE_SINGLE)
											flag:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
											flag:SetCode(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)
											flag:SetValue(id)
											flag:SetReset(RESET_CHAIN)
											ec1:RegisterEffect(flag)
										end
									end
									all_mats:Merge(mats)
								end
							end
						end
					end
					all_mats:Merge(mg)
					
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local cancel=Duel.IsSummonCancelable()
					local chosen_mats=all_mats:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
					for ec2 in aux.Next(all_mats) do
						if ec2:GetFlagEffect(1006)>0 then
							ec2:ResetFlagEffect(1006)
						end
						for _,flag in ipairs({ec2:IsHasEffect(EFFECT_GLITCHY_EXTRA_MATERIAL_FLAG)}) do
							if flag and flag.GetLabel then
								flag:Reset()
							end
						end
					end
					
					local extra_mats=Group.CreateGroup()
					local valid_effs,extra_opt={},{}
					for mc in aux.Next(chosen_mats) do
						for _,ce in ipairs(egroup) do
							if --[[not mg:IsContains(mc) and ]]ce and ce.GetLabel and ce:GetTarget()(ce,mc) then
								--register card as possible extra material
								extra_mats:AddCard(mc)
								mc:RegisterFlagEffect(1006,RESET_CHAIN,0,1)
								--register description
								local d=ce:GetDescription()
								for _,desc in ipairs(extra_opt) do
									if desc==d then
										d=false
										break
									end
								end
								if d then
									table.insert(extra_opt,d)
									table.insert(valid_effs,ce)
								end
							end
						end
					end
					if #extra_opt>0 and (chosen_mats:IsExists(aux.NOT(aux.IsInGroup),1,nil,mg) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) then
						local ecount=0
						while aux.GetValueType(extra_mats)=="Group" and #extra_mats>0 and #extra_opt>0 and (ecount==0 or chosen_mats:IsExists(aux.PureExtraFilterLoop,1,nil,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) or Duel.SelectYesNo(tp,aux.Stringid(1006,0))) do
							local opt=Duel.SelectOption(tp,table.unpack(extra_opt))+1
							local eff=valid_effs[opt]
							local _,max=eff:GetValue()(eff,nil)
							if not max or max==0 then max=#extra_mats end
							local emats=extra_mats:SelectSubGroup(tp,aux.ExtraMaterialFilterGoal,false,1,max,extra_mats)
							--local emats=extra_mats:FilterSelect(tp,aux.ExtraMaterialFilterSelect,1,max,nil,eff,eff:GetTarget())
							if #emats>0 then
								for tc in aux.Next(emats) do
									local e1=Effect.CreateEffect(tc)
									e1:SetType(EFFECT_TYPE_SINGLE)
									e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
									e1:SetCode(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
									e1:SetLabel(ecount)
									e1:SetOperation(eff:GetOperation())
									e1:SetReset(RESET_CHAIN)
									tc:RegisterEffect(e1,true)
									extra_mats:RemoveCard(tc)
								end
							end
							table.remove(extra_opt,opt)
							table.remove(valid_effs,opt)
							ecount=ecount+1
						end
					end
					for ec4 in aux.Next(chosen_mats) do
						if ec4:GetFlagEffect(1006)>0 and not ec4:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL) then
							ec4:ResetFlagEffect(1006)
						end
					end
					
					if chosen_mats then
						chosen_mats:KeepAlive()
						e:SetLabelObject(chosen_mats)
						return true
					else
						return false
					end
				end
			end
end

Auxiliary.LinkOperation = function(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Auxiliary.LExtraMaterialCount(g,c,tp)
				
				local rg=g:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,1006),nil)
				g:Sub(rg)
				local opt=0
				Duel.SendtoGrave(rg,REASON_MATERIAL+REASON_LINK)
				
				local ecount=0
				while #g>0 do
					local extra_g=Group.CreateGroup()
					local extra_op=false
					for tc in aux.Next(g) do
						local ce=tc:IsHasEffect(EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)
						if ce and ce.GetLabel and ce:GetLabel()==ecount then
							extra_g:AddCard(tc)
							if not extra_op then
								extra_op=ce:GetOperation()
							end
						end
					end
					if #extra_g>0 then
						g:Sub(extra_g)
						for tc in aux.Next(extra_g) do
							tc:ResetFlagEffect(1006)
						end
						extra_op(extra_g)
						extra_g:DeleteGroup()
					end
					ecount=ecount+1
				end

				g:DeleteGroup()
			end
end

Auxiliary.LCheckGoal = function(sg,tp,lc,gf,lmat)
	for _,e in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_GLITCHY_EXTRA_LINK_MATERIAL)}) do
		local id=e:GetLabel()
		local val=e:GetValue()
		if val then
			local _,valmax=val(e,nil)
			if not (not sg or not sg:IsExists(aux.ExtraMaterialMaxCheck,valmax+1,nil,id)) then
				return false
			end
		end
	end
	return _LCheckGoal(sg,tp,lc,gf,lmat)
end




--Other Auxs
--Functions that handle the operation of returning cards that were banished temporarily to their previous location
function Auxiliary.ReturnCon(timep)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local id=e:GetLabel()
				return (not timep or Duel.GetTurnPlayer()==timep) and e:GetLabelObject():IsExists(function(c,cd) return c:GetFlagEffect(cd)>0 end,1,nil,id)
			end
end
function Auxiliary.ReturnOp(timect)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local id,turn,ct=e:GetLabel()
				if ct~=turn then return e:SetLabel(id,turn,ct+1) end
				local g=e:GetLabelObject()
				local tg=g:Filter(function(c,cd) return c:GetFlagEffect(cd)>0 end,nil,id)
				for tc in aux.Next(tg) do
					if tc:IsPreviousLocation(LOCATION_ONFIELD) then
						Duel.ReturnToField(tc)
					elseif tc:IsPreviousLocation(LOCATION_GRAVE) then
						Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN,tc:GetPreviousControler())
					elseif tc:IsPreviousLocation(LOCATION_HAND) then
						Duel.SendtoHand(tc,tc:GetPreviousControler(),REASON_EFFECT+REASON_RETURN)
					elseif tc:IsPreviousLocation(LOCATION_DECK) or (tc:IsPreviousLocation(LOCATION_EXTRA) and tc:IsPreviousPosition(POS_FACEDOWN)) then
						Duel.SendtoDeck(tc,tc:GetPreviousControler(),SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_RETURN)
					elseif tc:IsPreviousLocation(LOCATION_EXTRA) and tc:IsPreviousPosition(POS_FACEUP) then
						Duel.SendtoExtraP(tc,tc:GetPreviousControler(),REASON_EFFECT+REASON_RETURN)
					end
				end
				g:DeleteGroup()
			end
end

--DUEL FUNCTIONS
function Duel.GetTargetParam()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
end

--FILTER AUXS

--Checks if (c) is controlled by (p) in the location (loc)
function Auxiliary.PLChk(c,p,loc)
	if aux.GetValueType(c)=="Card" then
		return (not p or c:IsControler(p)) and (not loc or c:IsLocation(loc))
	elseif aux.GetValueType(c)=="Group" then
		return c:IsExists(aux.PLChk,1,nil,p,loc)
	else
		return false
	end
end
function Auxiliary.AfterShuffle(g)
	for p=0,1 do
		if g:IsExists(aux.PLChk,1,nil,p,LOCATION_DECK) then
			Duel.ShuffleDeck(p)
		end
	end
end


--CARD MOVEMENT FUNCTIONS

--Banishes a card
--[[ pos = The position the card will be banished in. ]]
function Auxiliary.Banish(f,loc1,loc2,min,max,r,selp,actp,recp,pos,...)
	local extras={...}
	if not min then min=1 end
	if not max then max=min end
	if not r then r=REASON_EFFECT end
	if not pos then pos=POS_FACEUP end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local selp=(not selp or selp==0) and tp or 1-tp
				local actp=(not actp) and selp or (actp==0) and tp or 1-tp
				local recp=(recp==1) and 1-tp or (recp==0) and tp or nil
				Duel.Hint(HINT_SELECTMSG,selp,HINTMSG_REMOVE)
				local g=Duel.SelectMatchingCard(selp,aux.BanishFilter(f,r,actp,pos),tp,loc1,loc2,min,max,nil,table.unpack(extras))
				if #g>0 then
					if loc1&(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)>0 or loc2&(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)>0 then
						Duel.HintSelection(g)
					end
					local ct=Duel.Remove(g,pos,r,recp)
					return ct,g:Filter(aux.PLChk,nil,recp,LOCATION_REMOVED)
				end
				return 0
			end
end
--Banishes a card temporarily and returns it in its previous location eventually
--[[
timing = PHASE constant (the phase when the banishment ends)
timep = Can be NIL, 0 or 1. If not NIL, then the banishment ends only on the phase of the specified player
timect = Default value is 1. The banishment will end on the Nth phase (where N is ct)
timenext = If TRUE, then the banishment will end on the "next" Nth phase
id = The id for the flag that tracks the banished card
]]
function Auxiliary.BanishTemp(timing,timep,timect,timenext,id,f,loc1,loc2,min,max,r,selp,actp,recp,pos,...)
	local extras={...}
	if not timing then timing=PHASE_END end
	if not timect then timect=1 end
	if not min then min=1 end
	if not max then max=min end
	if not r then r=REASON_EFFECT end
	if not pos then pos=POS_FACEUP end
	r=r|REASON_TEMPORARY
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local timetp=(not timep) and 0 or (timep==tp) and 0x10000000 or 0x20000000
				local selp=(not selp or selp==0) and tp or 1-tp
				local actp=(not actp) and selp or (actp==0) and tp or 1-tp
				local recp=(recp==1) and 1-tp or (recp==0) and tp or nil
				Duel.Hint(HINT_SELECTMSG,selp,HINTMSG_REMOVE)
				local g=Duel.SelectMatchingCard(selp,aux.BanishFilter(f,r,actp,pos),tp,loc1,loc2,min,max,nil,table.unpack(extras))
				if #g>0 then
					if loc1&(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)>0 or loc2&(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)>0 then
						Duel.HintSelection(g)
					end
					local ct=Duel.Remove(g,pos,r,recp)
					local sg=g:Filter(aux.PLChk,nil,recp,LOCATION_REMOVED)
					if ct>0 and #sg>0 then
						local c=e:GetHandler()
						local tc=sg:GetFirst()
						while tc do
							tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
							tc=sg:GetNext()
						end
						sg:KeepAlive()
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						e1:SetCode(EVENT_PHASE+timing)
						e1:SetLabelObject(sg)
						e1:SetCountLimit(1)
						e1:SetCondition(aux.ReturnCon(timep,timect))
						e1:SetOperation(aux.ReturnOp())
						if timenext and (not timep or Duel.GetTurnPlayer()==timep) and Duel.GetCurrentPhase()==timing then
							e1:SetLabel(id,timect+1,1)
							e1:SetReset(RESET_PHASE+timing+timetp,timect+1)
						else
							e1:SetLabel(id,timect,1)
							e1:SetReset(RESET_PHASE+timing+timetp,timect)
						end
						Duel.RegisterEffect(e1,tp)
					end
					return ct,g:Filter(aux.PLChk,nil,recp,LOCATION_REMOVED)
				end
				return 0
			end
end

--Searches a card(s): adds from the Deck to the hand, and ONLY FROM THE DECK
function Auxiliary.Search(f,min,max,r,selp,recp,...)
	local extras={...}
	if not min then min=1 end
	if not max then max=min end
	if not r then r=REASON_EFFECT end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local selp=(not selp or selp==0) and tp or 1-tp
				local recp=(recp==1) and 1-tp or (recp==0) and tp or nil
				Duel.Hint(HINT_SELECTMSG,selp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(selp,aux.SearchFilter(f,r),tp,LOCATION_DECK,0,min,max,nil,table.unpack(extras))
				if #g>0 then
					local ct=Duel.SendtoHand(g,recp,r)
					if ct>0 and aux.PLChk(g,recp,LOCATION_HAND) then
						Duel.ConfirmCards(1-selp,g:Filter(aux.PLChk,nil,recp,LOCATION_HAND))
					end
					return ct,g:Filter(aux.PLChk,nil,recp,LOCATION_HAND)
				end
				return 0
			end
end

--SPSUMMON
function Auxiliary.SPSummonSelfTarget(check,pos)
	if not check then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,pos)
					end
					Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,pos)
					end
					Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
				end
	end
end

--Special Summons a card(s)
--[[
sumtype = The type of Special Summon that will be executed. Default value is 0 (for regular Special Summons)
sump = The player that performs the Special Summon
recp = The player that receives the Special Summoned card
ign1 = If TRUE, the Special Summon ignores Summoning Conditions
ign2 = If TRUE, the Special Summon ignores the Revive Limit (for example, you can SS a Synchro monster from the GY even if it was not properly Summoned from the ED previously)
pos = The position the cards will be Special Summoned in.
]]
function Auxiliary.SPSummon(f,loc1,loc2,min,max,selp,sumtype,sump,recp,ign1,ign2,pos,...)
	local extras={...}
	if not min then min=1 end
	if not max then max=min end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local selp=(not selp or selp==0) and tp or 1-tp
				local sump=(not sump) and selp or (sump==0) and tp or 1-tp
				local recp=(not recp) and sump or (recp==0) and tp or 1-tp
				Duel.Hint(HINT_SELECTMSG,selp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(selp,aux.SPSummonFilter(f,e,sumtype,sump,ign1,ign2,pos),tp,loc1,loc2,min,max,nil,table.unpack(extras))
				if #g>0 then
					local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos)
					return ct,g
				end
				return 0
			end
end
function Auxiliary.SPSummonStep(f,loc1,loc2,min,max,selp,sumtype,sump,recp,ign1,ign2,pos,...)
	local extras={...}
	if not min then min=1 end
	if not max then max=min end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local selp=(not selp or selp==0) and tp or 1-tp
				local sump=(not sump) and selp or (sump==0) and tp or 1-tp
				local recp=(not recp) and sump or (recp==0) and tp or 1-tp
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(selp,aux.SPSummonFilter(f,e,sumtype,sump,ign1,ign2,pos),tp,loc1,loc2,min,max,nil,table.unpack(extras))
				if #g>0 then
					local sg=Group.CreateGroup()
					for tc in aux.Next(g) do
						if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos) then
							sg:AddCard(tc)
						end
					end
					return #sg,sg
				end
				return 0
			end
end