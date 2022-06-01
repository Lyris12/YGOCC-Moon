--Custom Categories
CATEGORY_ZONE		  				= 0x1
CATEGORY_DISABLE_ZONE 				= 0x2
CATEGORY_PLACE_AS_CONTINUOUS_TRAP	= 0x4
CATEGORY_REDIRECT_ATTACK			= 0x8
CATEGORY_SET						= 0x10
CATEGORY_ACTIVATE					= 0x20
CATEGORY_ATTACH						= 0x40
CATEGORY_DETACH						= 0x80
CATEGORY_UPDATE_ATTRIBUTE			= 0x100
CATEGORY_UPDATE_RACE				= 0x200
CATEGORY_UPDATE_SETCODE				= 0x400
CATEGORY_LVCHANGE					= 0x800


--constants aliases
TYPE_ST			= TYPE_SPELL+TYPE_TRAP

ARCHE_FUSION	= 0x46

LOCATION_ALL = LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA
LOCATION_GB  = LOCATION_GRAVE+LOCATION_REMOVED

MAX_RATING = 14

RESET_TURN_SELF = RESET_SELF_TURN
RESET_TURN_OPPO = RESET_OPPO_TURN
RESETS_STANDARD_EXC_GRAVE = RESETS_STANDARD&~(RESET_LEAVE|RESET_TOGRAVE)


--Shortcuts
function Duel.IsExists(target,f,tp,loc1,loc2,min,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.IsExistingTarget or Duel.IsExistingMatchingCard
	
	return func(f,tp,loc1,loc2,min,exc,...)
end
function Duel.Select(hint,target,tp,f,pov,loc1,loc2,min,max,exc,...)
	if type(target)~="boolean" then return false end
	local func = (target==true) and Duel.SelectTarget or Duel.SelectMatchingCard
	local hint = hint or HINTMSG_TARGET
	
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=func(tp,f,pov,loc1,loc2,min,max,exc,...)
	return g
end
function Duel.Group(f,tp,loc1,loc2,exc,...)
	local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,...)
	return g
end
function Auxiliary.Faceup(f,...)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFaceup()
			end
end
function Auxiliary.Facedown(f,...)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsFacedown()
			end
end

--Custom Categories
if not global_effect_category_table_global_check then
	global_effect_category_table_global_check=true
	global_effect_category_table={}
	global_effect_info_table={}
end
function Effect.SetCustomCategory(e,cat)
	if not global_effect_category_table[e] then global_effect_category_table[e]={} end
	table.insert(global_effect_category_table[e],cat)
end
function Duel.SetCustomOperationInfo(ch,cat,g,ct,p,val,extra)
	if not global_effect_info_table[ch+1] or #global_effect_info_table[ch+1]>0 then
		global_effect_info_table[ch+1]={}
	end
	table.insert(global_effect_info_table[ch+1],{cat,g,ct,p,val,extra})
end

--Card Actions
function Duel.Attach(c,xyz)
	if aux.GetValueType(c)=="Card" then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(xyz,Group.FromCards(c))
		return xyz:GetOverlayGroup():IsContains(c)
			
	elseif aux.GetValueType(c)=="Group" then
		for tc in aux.Next(c) do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		Duel.Overlay(xyz,c)
		return c:FilterCount(function (card,group) return group:IsContains(card) end, nil, xyz:GetOverlayGroup())
	end
end

function Card.Recreate(c,...)
	local x={...}
	if #x==0 then return end
	local datalist={CARDDATA_CODE,CARDDATA_ALIAS,CARDDATA_SETCODE,CARDDATA_TYPE,CARDDATA_LEVEL,CARDDATA_ATTRIBUTE,CARDDATA_RACE,CARDDATA_ATTACK,CARDDATA_DEFENSE,CARDDATA_LSCALE,CARDDATA_RSCALE}
	for i,newval in ipairs(x) do
		if newval then
			c:SetCardData(datalist[i],newval)
		end
	end
end

function Duel.Negate(tc,e,reset,notfield,forced)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e1,forced)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	if not notfield then
		e2:SetValue(RESET_TURN_SET)
	end
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
	tc:RegisterEffect(e2,forced)
	if not notfield and tc:IsType(TYPE_TRAPMONSTER) then
		local e=Effect.CreateEffect(e:GetHandler())
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
		tc:RegisterEffect(e,forced)
		return e1,e2,e
	end
	return e1,e2
end
function Duel.NegateInGY(tc,e,reset)
	if not reset then reset=0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+reset)
	tc:RegisterEffect(e2)
	return e1,e2
end
function Duel.PositionChange(c)
	return Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
function Duel.Search(g,tp)
	local ct=Duel.SendtoHand(g,tp,REASON_EFFECT)
	local cg=g:Filter(aux.PLChk,nil,tp,LOCATION_HAND)
	if #cg>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	return ct,#cg
end

function Duel.ShuffleIntoDeck(g,p)
	local ct=Duel.SendtoDeck(g,p,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 and aux.PLChk(g,p,LOCATION_DECK) then
		aux.AfterShuffle(g)
		if aux.GetValueType(g)=="Card" and aux.PLChk(g,p,LOCATION_DECK) then
			return 1
		elseif aux.GetValueType(g)=="Group" then
			return g:FilterCount(aux.PLChk,nil,p,LOCATION_DECK)
		end
	end
	return 0
end
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
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	for p=0,1 do
		if g:IsExists(aux.PLChk,1,nil,p,LOCATION_DECK) then
			Duel.ShuffleDeck(p)
		end
	end
end

--Card Filters
function Card.IsMonster(c,typ)
	return c:IsType(TYPE_MONSTER) and (type(typ)~="number" or c:IsType(typ))
end
function Card.IsST(c,typ)
	return c:IsType(TYPE_ST) and (type(typ)~="number" or c:IsType(typ))
end
function Card.MonsterOrFacedown(c)
	return c:IsMonster() or c:IsFacedown()
end

function Card.HasAttack(c)
	return true
end
function Card.HasDefense(c)
	return not c:IsOriginalType(TYPE_LINK)
end

function Card.HasHighest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)>val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasLowest(c,stat,g,f)
	if not g then g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):Filter(Card.IsFaceup,nil) end
	local func	=	function(tc,val,fil)
						return stat(tc)<val and (not fil or fil(tc))
					end
	return not g:IsExists(func,1,c,stat(c),f)
end
function Card.HasHighestATK(c,g,f)
	return c:HasHighest(Card.GetAttack,g,f)
end
function Card.HasLowestATK(c,g,f)
	return c:HasLowest(Card.GetAttack,g,f)
end
function Card.HasHighestDEF(c,g,f)
	return c:HasHighest(Card.GetDefense,g,f)
end
function Card.HasLowestDEF(c,g,f)
	return c:HasLowest(Card.GetDefense,g,f)
end

function Card.HasOriginalLevel(c)
	return not c:IsOriginalType(TYPE_XYZ+TYPE_LINK)
end
function Card.IsOriginalType(c,typ)
	return c:GetOriginalType()&typ>0
end

function Card.GetRating(c)
	local list={false,false,false,false}
	if c:HasLevel() then
		list[1]=(c:GetLevel())
	end
	if c:IsOriginalType(TYPE_XYZ) then
		list[2]=(c:GetRank())
	end
	if c:IsOriginalType(TYPE_LINK) then
		list[3]=(c:GetLink())
	end
	if c:IsOriginalType(TYPE_TIMELEAP) then
		list[4]=(c:GetFuture())
	end
	return list
end
	
function Card.IsRating(c,n,lv,rk,link,fut)
	if lv and type(lv)=="boolean" then lv=n end
	if rk and type(rk)=="boolean" then rk=n end
	if link and type(link)=="boolean" then link=n end
	if fut and type(fut)=="boolean" then fut=n end
	return (lv and c:HasLevel() and c:IsLevel(lv)) or (rk and c:IsOriginalType(TYPE_XYZ) and c:IsRank(rk)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLink(link))
		or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFuture(fut))
end
function Card.IsRatingAbove(c,n,lv,rk,link,fut)
	if lv and type(lv)=="boolean" then lv=n end
	if rk and type(rk)=="boolean" then rk=n end
	if link and type(link)=="boolean" then link=n end
	if fut and type(fut)=="boolean" then fut=n end
	return (lv and c:HasLevel() and c:IsLevelAbove(lv)) or (rk and c:IsOriginalType(TYPE_XYZ) and c:IsRankAbove(rk)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkAbove(link))
		or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFutureAbove(fut))
end
function Card.IsRatingBelow(c,n,lv,rk,link,fut)
	if lv and type(lv)=="boolean" then lv=n end
	if rk and type(rk)=="boolean" then rk=n end
	if link and type(link)=="boolean" then link=n end
	if fut and type(fut)=="boolean" then fut=n end
	return (lv and c:HasLevel() and c:IsLevelBelow(lv)) or (rk and c:IsOriginalType(TYPE_XYZ) and c:IsRankBelow(rk)) or (link and c:IsOriginalType(TYPE_LINK) and c:IsLinkBelow(link))
		or (fut and c:IsOriginalType(TYPE_TIMELEAP) and c:IsFutureBelow(fut))
end

function Card.ByBattleOrEffect(c,f,p)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and (not f or re and f(re:GetHandler(),e,tp,eg,ep,ev,re,r,rp)) and (not p or rp~=(1-p))
			end
end

--Chain Info
function Duel.GetTargetParam()
	return Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
end

--Columns
function Card.GlitchyGetColumnGroup(c,left,right)
	local left = (left and type(left)=="number" and left>=0) and left or 0
	local right = (right and type(right)=="number" and right>=0) and right or 0
	if left==0 and right==0 then
		return c:GetColumnGroup()
	else
		local f = 	function(card,refc,val)
						local refseq
						if refc:GetSequence()<5 then
							refseq=refc:GetSequence()
						else
							if refc:GetSequence()==5 then
								refseq = 1
							elseif refc:GetSequence()==6 then
								refseq = 3
							end
						end
						
						if card:GetSequence()<5 then
							if card:IsControler(refc:GetControler()) then
								return math.abs(refseq-card:GetSequence())==val
							else
								return math.abs(refseq+card:GetSequence()-4)==val
							end
						
						elseif card:GetSequence()==5 then
							local seq = card:IsControler(refc:GetControler()) and 1 or 3
							return math.abs(refseq-seq)==val
						elseif card:GetSequence()==6 then
							local seq = card:IsControler(refc:GetControler()) and 3 or 1
							return math.abs(refseq-seq)==val
						end
					end
					
		local lg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,left)
		local cg=c:GetColumnGroup()
		local rg=Duel.Group(f,c:GetControler(),LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil,c,right)
		cg:Merge(lg)
		cg:Merge(rg)
		return cg
	end
end

--Descriptions
function Effect.Desc(e,id,...)
	local x = {...}
	local code = #x>0 and x[1] or e:GetOwner():GetOriginalCode()
	return e:SetDescription(aux.Stringid(code,id))
end

function Auxiliary.Option(id,tp,desc,...)
	local list={...}
	local off=1
	local ops={}
	local opval={}
	local truect=1
	for ct,b in ipairs(list) do
		local check=b
		local localid=id
		local localdesc=desc+truect-1
		if type(b)=="table" then
			check=b[1]
			localid=b[2]
			localdesc=b[3]
		else
			truect=truect+1
		end
		if check==true then
			ops[off]=aux.Stringid(localid,localdesc)
			opval[off]=ct-1
			off=off+1
		end
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	Duel.Hint(HINT_OPSELECTED,1-tp,ops[op])
	return sel
end

--Flag Effects
function Card.HasFlagEffect(c,id)
	return c:GetFlagEffect(id)>0
end
function Card.UpdateFlagEffectLabel(c,id,ct)
	if not ct then ct=1 end
	return c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+ct)
end
function Duel.UpdateFlagEffectLabel(p,id,ct)
	if not ct then ct=1 end
	return Duel.SetFlagEffectLabel(p,id,Duel.GetFlagEffectLabel(p,id)+ct)
end

--Gain Effect
function Auxiliary.GainEffectType(c,oc,reset)
	if not oc then oc=c end
	if not reset then reset=0 end
	if not c:IsType(TYPE_EFFECT) then
		local e=Effect.CreateEffect(oc)
		e:SetType(EFFECT_TYPE_SINGLE)
		e:SetCode(EFFECT_ADD_TYPE)
		e:SetValue(TYPE_EFFECT)
		e:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e,true)
	end
end

--Locations
function Card.IsBanished(c)
	return c:IsLocation(LOCATION_REMOVED)
end
function Card.IsInExtra(c,fu)
	return c:IsLocation(LOCATION_EXTRA) and (fu==nil or fu and c:IsFaceup() or not fu and c:IsFacedown())
end
function Card.IsInMMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function Card.IsInEMZ(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>=5
end

function Card.NotBanishedOrFaceup(c)
	return not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()
end
function Card.NotInExtraOrFaceup(c)
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end

--Phases
function Duel.IsDrawPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_DRAW
end
function Duel.IsStandbyPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_STANDBY
end
function Duel.IsMainPhase(tp,ct)
	return (not tp or Duel.GetTurnPlayer()==tp) and (not ct and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) or ct==1 and Duel.GetCurrentPhase()==PHASE_MAIN1 or ct==2 and Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function Duel.IsBattlePhase(tp)
	local ph=Duel.GetCurrentPhase()
	return (not tp or Duel.GetTurnPlayer()==tp) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function Duel.IsEndPhase(tp)
	return (not tp or Duel.GetTurnPlayer()==tp) and Duel.GetCurrentPhase()==PHASE_END
end
-----------------------------------------------------------------------
function Card.Ignition(c,desc,ctg,prop,range,ctlim,cond,cost,tg,op,reset,quickcon)
	local range = range and range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if type(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if type(prop)=="number" then
		e1:SetProperty(prop)
	end	
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	c:RegisterEffect(e1)
	--
	if quickcon then
		local e2=e1:Clone()
		if desc then
			e2:Desc(desc+1)
		end
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		if e1:GetCategory()&(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)>0 then
			local prop = type(prop)=="number" and prop or 0
			e2:SetProperty(prop+EFFECT_FLAG_DAMAGE_STEP)
			quickcon=aux.AND(quickcon,aux.ExceptOnDamageCalc)
		end
		if ctlim and type(ctlim)=="number" then
			e1:SetCountLimit(ctlim,EFFECT_COUNT_CODE_SINGLE)
			e2:SetCountLimit(ctlim,EFFECT_COUNT_CODE_SINGLE)
		end
		if cond then
			e2:SetCondition(aux.AND(cond,quickcon))
		else
			e2:SetCondition(quickcon)
		end
		c:RegisterEffect(e2)
		return e1,e2
	end
	return e1
end
function Card.Activate(c,desc,ctg,prop,event,ctlim,cond,cost,tg,op,handcon)
	local event = event and event or EVENT_FREE_CHAIN
	local range = range and range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if type(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil then
		e1:SetProperty(prop)
	end	
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(event)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	if reset then
		e1:SetReset(reset)
	end
	c:RegisterEffect(e1)
	--
	if handcon and c:GetOriginalType()&(TYPE_QUICKPLAY+TYPE_TRAP)>0 then
		local handcode = c:GetOriginalType()&TYPE_TRAP==0 and EFFECT_QP_ACT_IN_NTPHAND or EFFECT_TRAP_ACT_IN_HAND
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
		e2:SetRange(LOCATION_HAND)
		e2:SetCondition(handcon)
		c:RegisterEffect(e2)
		return e1,e2
	end
	return e1
end
function Card.Quick(c,forced,desc,ctg,prop,event,range,ctlim,cond,cost,tg,op)
	if not event then event=EVENT_FREE_CHAIN end
	local range = range or (c:IsOriginalType(TYPE_MONSTER)) and LOCATION_MZONE or (c:IsOriginalType(TYPE_FIELD)) and LOCATION_FZONE
	local quick_type=(not forced) and EFFECT_TYPE_QUICK_O or EFFECT_TYPE_QUICK_F
	---
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:Desc(desc)
	end
	if ctg then
		if type(ctg)=="table" then
			e1:SetCategory(ctg[1])
			if #ctg>1 then
				e1:SetCustomCategory(ctg[2])
			end
		else
			e1:SetCategory(ctg)
		end
	end
	if prop~=nil then
		if type(prop)=="boolean" and prop==true then
			e1:SetProperty(EFFECT_FLAG_DELAY)
		else
			e1:SetProperty(prop)
		end
	end	
	e1:SetType(quick_type)
	e1:SetCode(event)
	e1:SetRange(range)
	if ctlim then
		if type(ctlim)=="table" then
			local flag=#ctlim>2 and ctlim[3] or 0
			e1:SetCountLimit(ctlim[1],c:GetOriginalCode()+ctlim[2]*100+flag)
		else
			e1:SetCountLimit(ctlim)
		end
	end
	if cond then
		e1:SetCondition(cond)
	end
	if cost then
		e1:SetCost(cost)
	end
	if tg then
		e1:SetTarget(tg)
	end
	if op then
		e1:SetOperation(op)
	end
	c:RegisterEffect(e1)
	return e1
end