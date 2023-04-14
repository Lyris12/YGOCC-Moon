--coded by Lyris
--調波召喚
--Not yet finalized values
--Custom constants
EFFECT_CANNOT_BE_HARMONIZED_MATERIAL=531
EFFECT_MUST_BE_HARMONIZED_MATERIAL	=532
EFFECT_EXTRA_HARMONIZED_MATERIAL	=533
TYPE_HARMONY						=0x80000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_HARMONY
CTYPE_HARMONY						=0x800
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_HARMONY
SUMMON_TYPE_HARMONY					=SUMMON_TYPE_SPECIAL+531

REASON_HARMONY						=0x2000000000
PHASE_MAIN							=0x400

--Custom Type Table
Auxiliary.Harmonies={} --number as index = card, card as index = function() is_synchro
table.insert(aux.CannotBeEDMatCodes,EFFECT_CANNOT_BE_HARMONIZED_MATERIAL)

--overwrite constants
TYPE_EXTRA							=TYPE_EXTRA|TYPE_HARMONY

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason =
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Harmonies[c] then
		tpe=tpe|TYPE_HARMONY
		if not Auxiliary.Harmonies[c]() then
			tpe=tpe&~TYPE_SYNCHRO
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Harmonies[rc] then
		rs=rs|REASON_HARMONY
	end
	return rs
end

--Custom Functions
function Card.IsCanBeHarmonizedMaterial(c,hc)
	if c:IsOnField() and c:IsFacedown() then return false end
	local tef={c:IsHasEffect(EFFECT_CANNOT_BE_HARMONIZED_MATERIAL)}
	for _,te in ipairs(tef) do
		if (type(te:GetValue())=="function" and te:GetValue()(te,hc)) or te:GetValue()==1 then return false end
	end
	return true
end
function Auxiliary.AddOrigHarmonyType(c,issynchro)
	table.insert(Auxiliary.Harmonies,c)
	Auxiliary.Customs[c]=true
	local issynchro=issynchro==nil and false or issynchro
	Auxiliary.Harmonies[c]=function() return issynchro end
end
function Auxiliary.AddHarmonyProc(c,ph,...)
	--ph - Phase(s) to be used as Harmonized Material
	--... format - any number of materials  use aux.TRUE for generic materials
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local t={...}
	local list={}
	local min,max
	for i=1,#t do
		if type(t[#t])=='number' then
			max=t[#t]
			table.remove(t)
			if type(t[#t])=='number' then
				min=t[#t]
				table.remove(t)
			else
				min=max
				max=99
			end
			table.insert(list,{t[#t],min,max})
			table.remove(t)
		end
		if #t<2 then break end
	end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(Auxiliary.HarmonyCondition(table.unpack(list)))
	ge2:SetTarget(Auxiliary.HarmonyTarget(table.unpack(list)))
	ge2:SetOperation(Auxiliary.HarmonyOperation(ph))
	ge2:SetValue(SUMMON_TYPE_HARMONY)
	c:RegisterEffect(ge2)
	if not aux.HarmonyGlobalCheck then
		aux.HarmonyGlobalCheck=true
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_ADJUST)
		ge3:SetOperation(aux.HCheck)
		Duel.RegisterEffect(ge3,0)
		local ge4=ge3:Clone()
		ge4:SetCode(EVENT_CHAIN_SOLVED)
		Duel.RegisterEffect(ge4,0)
	end
	local ge5=Effect.CreateEffect(c)
    ge5:SetType(EFFECT_TYPE_SINGLE)
    ge5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    ge5:SetCode(EFFECT_SPSUMMON_COST)
	ge5:SetCost(aux.HCondition)
	c:RegisterEffect(ge5)
	local ge7=Effect.CreateEffect(c)
	ge7:SetType(EFFECT_TYPE_SINGLE)
	ge7:SetRange(LOCATION_MZONE)
	ge7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ge7:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(ge7)
end
function Auxiliary.HCheckRecursive(c,tp,sg,mg,hc,ct,max,...)
	sg:AddCard(c)
	ct=ct+1
	local funs,chk={...},false
	for i=1,#funs do
		if funs[i][1](c) then
			chk=true
		end
	end
	local res=chk and (Auxiliary.HCheckGoal(tp,sg,hc,ct,...)
		or (ct<max and mg:IsExists(aux.HCheckRecursive,1,sg,tp,sg,mg,hc,ct,max,...)))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function Auxiliary.HCheckGoal(tp,sg,Hc,ct,...)
	local funs,min,max={...},0,0
	for i=1,#funs do
		local locf,locmin,locmax=funs[i][1],funs[i][2],funs[i][3]
		if not sg:IsExists(locf,locmin,nil) or sg:IsExists(locf,locmax+1,nil) then return false end
		min=min+locmin
		max=max+locmax
	end
	return ct>=min and ct<=max and Duel.GetLocationCountFromEx(tp,tp,sg,Hc)>0
		and not sg:IsExists(Auxiliary.HarmonizedUncompatibilityFilter,1,nil,sg,Hc,tp)
end
function Auxiliary.HarmonizedUncompatibilityFilter(c,sg,hc,tp)
	local mg=sg:Filter(aux.TRUE,c)
	return not Auxiliary.HarmonizedCheckOtherMaterial(c,mg,hc,tp)
end
function Auxiliary.HarmonizedCheckOtherMaterial(c,mg,hc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL,tp)}
	for _,te in pairs(le) do
		local f=te:GetValue()
		if f and type(f)=="function" and not f(te,hc,mg) then return false end
	end
	return true
end
function Auxiliary.HarmonizedExtraFilter(c,lc,tp,...)
	local flist={...}
	local check=false
	for i=1,#flist do
		if flist[i][1](c) then
			check=true
		end
	end
	local tef1={c:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL,tp)}
	local ValidSubstitute=false
	for _,te1 in ipairs(tef1) do
		local con=te1:GetCondition()
		if (not con or con(c,lc,1)) then ValidSubstitute=true end
	end
	if not ValidSubstitute then return false end
	if c:IsLocation(LOCATION_ONFIELD) and not c:IsFaceup() then return false end
	return c:IsCanBeHarmonizedMaterial(lc) and (not flist or #flist<=0 or check)
end
function Auxiliary.HarmonyCondition(...)
	local funs={...}
	local max=0
	for i=1,#funs do
		max=max+funs[i][3]
	end
	return  function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(Card.IsCanBeHarmonizedMaterial,tp,LOCATION_REMOVED,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.HarmonizedExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_HARMONIZED_MATERIAL)
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return mg:IsExists(Auxiliary.HCheckRecursive,1,nil,tp,Group.CreateGroup(),mg,c,0,max,table.unpack(funs))
			end
end
function Auxiliary.HarmonyTarget(...)
	local funs,min,max={...},0,0
	for i=1,#funs do min=min+funs[i][2] max=max+funs[i][3] end
	if max>99 then max=99 end
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(Card.IsCanBeHarmonizedMaterial,tp,LOCATION_REMOVED,0,nil,c)
				local mg2=Duel.GetMatchingGroup(Auxiliary.HarmonizedExtraFilter,tp,0xff,0xff,nil,c,tp,table.unpack(funs))
				if #mg2>0 then mg:Merge(mg2) end
				local bg=Group.CreateGroup()
				local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_HARMONIZED_MATERIAL)}
				for _,te in ipairs(ce) do
					local tc=te:GetHandler()
					if tc then bg:AddCard(tc) end
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				local finish=false
				while not (#sg>=max) do
					finish=Auxiliary.HCheckGoal(tp,sg,c,#sg,table.unpack(funs))
					local cg=mg:Filter(Auxiliary.HCheckRecursive,sg,tp,sg,mg,c,#sg,max,table.unpack(funs))
					if #cg==0 then break end
					local cancel=not finish
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,min,max)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
							if (#sg>=max) then finish=true end
						else
							sg:RemoveCard(tc)
						end
					elseif #bg>0 and #sg<=#bg then
						return false
					end
				end
				if finish then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function Auxiliary.HarmonyOperation(ph)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(true) end
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				local dg=Group.CreateGroup()
				for tc in aux.Next(g) do
					local tef={tc:IsHasEffect(EFFECT_EXTRA_HARMONIZED_MATERIAL)}
					if #tef==0 then dg:AddCard(tc)
					else for i=1,#tef do
						local op=tef[i]:GetOperation()
						if op then
							op(tc,tp)
						else
							dg:AddCard(tc)
						end
					end end
				end
				Duel.SendtoDeck(dg,nil,2,REASON_MATERIAL+REASON_HARMONY)
				g:DeleteGroup()
				local cph=Duel.GetCurrentPhase()
				local mph=ph
				local p
				for i=0,10 do
					p=ph&1<<i
					if p>0 then
						if p==PHASE_BATTLE then
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
							e1:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
							e1:SetCondition(aux.HarmonizedMaterialPSkipCon)
							local rs,tn=3,0
							if Duel.GetTurnPlayer()==tp and cph>=PHASE_BATTLE_START and cph<=PHASE_BATTLE then
								tn=Duel.GetTurnCount()
							end
							if Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_BP) then rs=rs+2 end
							e1:SetLabel(tn,p)
							e1:SetOperation(aux.HarmonizedMaterialPSkipBP)
							e1:SetReset(RESET_PHASE+PHASE_BATTLE,rs+Duel.GetFlagEffect(tp,531+p))
							Duel.RegisterEffect(e1,tp)
						elseif p==PHASE_MAIN then
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetCode(EFFECT_SKIP_M1)
							e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
							e1:SetTargetRange(1,0)
							e1:SetCondition(aux.HarmonizedMaterialPSkipCon)
							local rs,tn=3,0
							if Duel.GetTurnPlayer()==tp and cph==PHASE_MAIN1 then
								tn=Duel.GetTurnCount()
							end
							if Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_M1) then rs=rs+2 end
							e1:SetLabel(tn,PHASE_MAIN1+p)
							e1:SetReset(RESET_PHASE+PHASE_MAIN1,rs+Duel.GetFlagEffect(tp,531+p))
							Duel.RegisterEffect(e1,tp)
							local e2=e1:Clone()
							e2:SetCode(EFFECT_SKIP_M2)
							rs,tn=3,0
							e2:SetLabel(tn,PHASE_MAIN2+p)
							e2:SetLabelObject(e1)
							e2:SetCondition(aux.HarmonizedMaterialPSkipCon)
							if Duel.GetTurnPlayer()==tp and cph==PHASE_MAIN2 then
								tn=Duel.GetTurnCount()
							end
							if Duel.IsPlayerAffectedByEffect(tp,EFFECT_SKIP_M2) then rs=rs+2 end
							e2:SetReset(RESET_PHASE+PHASE_MAIN2,rs+Duel.GetFlagEffect(tp,531+p))
							Duel.RegisterEffect(e2,tp)
							e1:SetLabelObject(e2)
						else
							local code=EFFECT_SKIP_DP
							if p==PHASE_STANDBY then
								code=EFFECT_SKIP_SP
							elseif p==PHASE_MAIN1 then
								code=EFFECT_SKIP_M1
							elseif p==PHASE_MAIN2 then
								code=EFFECT_SKIP_M2
							elseif p==PHASE_END then
								code=EFFECT_SKIP_EP
							end
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetCode(code)
							e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
							e1:SetTargetRange(1,0)
							e1:SetCondition(aux.HarmonizedMaterialPSkipCon)
							local rs,tn=3,0
							if Duel.GetTurnPlayer()==tp and cph==p then
								tn=Duel.GetTurnCount()
							end
							if Duel.IsPlayerAffectedByEffect(tp,code) then rs=rs+2 end
							e1:SetLabel(tn,p)
							e1:SetReset(RESET_PHASE+p,rs+Duel.GetFlagEffect(tp,531+p))
							Duel.RegisterEffect(e1,tp)
						end
						local l=Duel.GetFlagEffectLabel(tp,531+p)
						if l then l=l|p end
						Duel.RegisterFlagEffect(tp,531+p,RESET_PHASE+PHASE_END,Duel.GetFlagEffect(tp,531+p)+3,l or p)
					end
					ph=ph&~1<<i
					if ph==0 then break end
				end
				c:RegisterFlagEffect(531,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,3,mph)
				local g=Duel.GetMatchingGroup(aux.HPSkipFilter,tp,LOCATION_MZONE,0,nil,0x787)+c
				for tc in aux.Next(g) do
					local p=tc:GetFlagEffectLabel(531)
					local e2=Effect.CreateEffect(tc)
					e2:SetType(EFFECT_TYPE_FIELD)
					e2:SetTargetRange(0,1)
					e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetLabel(Duel.GetTurnCount(),p)
					e2:SetCondition(aux.HarmonizedMaterialPSkipCon)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,3)
					if p&PHASE_DRAW>0 then
						local e3=e2:Clone()
						e3:SetCode(EFFECT_SKIP_DP)
						Duel.RegisterEffect(e3,tp)
					end
					if p&PHASE_STANDBY>0 then
						local e3=e2:Clone()
						e3:SetCode(EFFECT_SKIP_SP)
						Duel.RegisterEffect(e3,tp)
					end
					if p&PHASE_MAIN1>0 or p&PHASE_MAIN>0 then
						local e3=e2:Clone()
						e3:SetCode(EFFECT_SKIP_M1)
						Duel.RegisterEffect(e3,tp)
					end
					if p&PHASE_BATTLE>0 then
						local e3=e2:Clone()
						e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						e3:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
						e3:SetOperation(aux.HarmonizedMaterialPSkipBP)
						Duel.RegisterEffect(e3,tp)
					end
					if p&PHASE_MAIN2>0 then
						local e3=e2:Clone()
						e3:SetCode(EFFECT_SKIP_M2)
						Duel.RegisterEffect(e3,tp)
					end
					if p&PHASE_END>0 then
						local e3=e2:Clone()
						e3:SetCode(EFFECT_SKIP_EP)
						Duel.RegisterEffect(e3,tp)
					end
				end
			end
end
function Auxiliary.HCheckFilter(c)
	return aux.Harmonies[c] and not c:IsControler(c:GetOwner())
end
function Auxiliary.HCheck(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.HCheckFilter,0,0xce,0xce,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_RULE) end
end
function Auxiliary.HCondition(e,te_or_c,tp)
	local c=e:GetHandler()
	return c:IsControler(c:GetOwner())
end
function Auxiliary.HPSkipFilter(c,p)
	return c:GetFlagEffect(531)>0 and c:GetFlagEffectLabel(531)&p>0
end
function Auxiliary.HPSkipCheck(g)
	local p=0
	for c in aux.Next(g:Clone()) do
		local ph=c:GetFlagEffectLabel(531)
		if ph then
			p=p|(ph&~PHASE_MAIN)
			if ph&PHASE_MAIN>0 then
				local l=Duel.GetFlagEffectLabel(c:GetControler(),533)
				if l then p=p|l end
			end
		end
	end
	local res=0
	for i=0,10 do if p&(1<<i)>0 then res=res+1 end end
	return res
end
function Auxiliary.HarmonizedMaterialPSkipCon(e)
	local tp=e:GetHandlerPlayer()
	local tn,p=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.HPSkipFilter,tp,LOCATION_MZONE,0,nil,p)
	if (Duel.GetTurnPlayer()==tp or #g>0) and Duel.GetTurnCount()>tn then
		local ef=e:GetLabelObject()
		if ef then
			local l=Duel.GetFlagEffectLabel(tp,533)
			if e:GetCode()==EFFECT_SKIP_M1 then
				if l then Duel.SetFlagEffectLabel(tp,533,l|PHASE_MAIN1)
				else Duel.RegisterFlagEffect(tp,533,RESET_PHASE+PHASE_END,0,1,PHASE_MAIN1) end
			else
				if l then Duel.SetFlagEffectLabel(tp,533,l|PHASE_MAIN2)
				else Duel.RegisterFlagEffect(tp,533,RESET_PHASE+PHASE_END,0,1,PHASE_MAIN2) end
			end
			ef:Reset()
		end
		if Duel.GetTurnPlayer()==tp then
			if aux.HPSkipCheck(g)>1 then Duel.RegisterFlagEffect(tp,532,RESET_PHASE+PHASE_END,0,3) end
		else
			if Duel.GetFlagEffect(tp,532)==0 then return false end
			for c in aux.Next(g) do
				if aux.HPSkipCheck(Group.FromCards(c))>1 then
					c:SetFlagEffectLabel(531,c:GetFlagEffectLabel(531)&~p)
				else c:ResetFlagEffect(531) end
			end
		end
		return true
	end
	return false
end
function Auxiliary.HarmonizedMaterialPSkipBP(e)
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	e:Reset()
end
