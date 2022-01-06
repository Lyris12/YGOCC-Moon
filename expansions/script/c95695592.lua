--Skyburner Hellcat
--Commissioned by: Leon Duvall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.condition)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.drawcon)
	e2:SetTarget(cid.drawtg)
	e2:SetOperation(cid.drawop)
	c:RegisterEffect(e2)
	if not cid.global_check then
		cid.global_check=true
		--register previous chains
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(cid.chainreg)
		Duel.RegisterEffect(ge1,0)
		--reset for turn
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(cid.resetchainreg)
		Duel.RegisterEffect(ge3,0)
	end
	--custom activity counters
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,cid.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_FLIPSUMMON,cid.counterfilter)
end
--GLOBAL VARIABLES AND GENERIC FILTERS
cid.chaintyp={[0]=0,[1]=0}
cid.chaincount={[0]={0,0,0},[1]={0,0,0}}

function cid.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
end
--REGISTER PREVIOUS CHAINS
function cid.chainreg(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	if rp==p or not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then return end
	cid.chaintyp[rp]=bit.bor(cid.chaintyp[rp],bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))
	if bit.band(cid.chaintyp[rp],TYPE_MONSTER)>0 then
		cid.chaincount[rp][1]=cid.chaincount[rp][1]+1
	end
	if bit.band(cid.chaintyp[rp],TYPE_SPELL)>0 then
		cid.chaincount[rp][2]=cid.chaincount[rp][2]+1
	end
	if bit.band(cid.chaintyp[rp],TYPE_TRAP)>0 then
		cid.chaincount[rp][3]=cid.chaincount[rp][3]+1
	end
end
--RESET FOR TURN
function cid.resetchainreg(e,tp,eg,ep,ev,re,r,rp)
	cid.chaintyp={[0]=0,[1]=0}
	cid.chaincount={[0]={0,0,0},[1]={0,0,0}}
end
--SPSUMMON
--filters
function cid.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf41) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND) and not c:IsRace(RACE_MACHINE)
end
---------
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and cid.chaintyp[rp]~=0
		and ((re:IsActiveType(TYPE_MONSTER) and cid.chaincount[rp][1]>1) or (re:IsActiveType(TYPE_SPELL) and cid.chaincount[rp][2]>1) or (re:IsActiveType(TYPE_TRAP) and cid.chaincount[rp][3]>1))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_FLIPSUMMON)==0 
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	if #g>0 then
		g:AddCard(e:GetHandler())
		if #g>=2 then
			local fid=e:GetHandler():GetFieldID()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			local tc=g:GetFirst()
			while tc do
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				tc=g:GetNext()
			end
			g:KeepAlive()
			--bounce back to hand during EP
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(g)
			e1:SetCondition(cid.thcon)
			e1:SetOperation(cid.thop)
			Duel.RegisterEffect(e1,tp)
			if Duel.GetCurrentPhase()==PHASE_END then
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
end
--BOUNCE DURING EP
--filters
function cid.thfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid and c:IsAbleToHand()
end
---------
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then
		return false
	end
	local g=e:GetLabelObject()
	if not g:IsExists(cid.thfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else 
		return true 
	end
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(cid.thfilter,nil,e:GetLabel())
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
end
--DRAW
function cid.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)>0
end
function cid.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end