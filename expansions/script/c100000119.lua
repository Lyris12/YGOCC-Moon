--Trappit Prototypit
--Trappolaniglio Prototipozzo

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card, then target 1 other "Trappit" card you control, even if Set;
	banish it, and if you do, Set that banished card to your field at the end of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.acthandcon)
	c:RegisterEffect(e3)
end
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end

--FE1
function s.setfilter1(c)
	if not c:IsFaceup() then return false end
	return (c:IsLocation(LOCATION_MZONE) and c:IsCanTurnSet()) or (not c:IsLocation(LOCATION_MZONE) and c:IsSSetable(true))
end
function s.setfilter2(c,tp)
	if not c:IsNormalTrap() or not c:IsSSetable() then return false end
	return c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.setfilter3(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
--E1
function s.gfilter(c,e,tp,exg,max,opt,ct)
	local check=false
	if opt&1==0 and c:IsOnField() and s.setfilter1(c) then
		check=true
		opt=opt|1
		ct=ct+1
	elseif opt&2==0 and c:IsInGY() and s.setfilter2(c,tp) then
		check=true
		opt=opt|2
		ct=ct+1
	elseif opt&4==0 and c:IsInGY() and Duel.GetMZoneCount(tp)>0 and s.setfilter3(c,e,tp) then
		check=true
		opt=opt|4
		ct=ct+1
	end
	
	if check then
		if ct==max then
			return true
		else
			exg:AddCard(c)
			local res=Duel.IsExists(false,s.gfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,exg,e,tp,exg,max,opt,ct)
			exg:RemoveCard(c)
			if res then
				return true
			end
		end
	end
	return false
end
function s.gcheck(g,e,tp)
	local exg=g:Clone()
	local res=Duel.IsExists(false,s.gfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,exg,e,tp,exg,#g,0,0)
	exg:DeleteGroup()
	if res then
		return true
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.AND(Card.IsNormalTrap,Card.IsAbleToRemoveAsCost),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if chk==0 then
		return e:IsCostChecked() and #g>0 and g:CheckSubGroup(s.gcheck,1,1,e,tp)
	end
	Duel.HintMessage(tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,e,tp)
	if #sg>0 then
		local ct=Duel.Banish(sg,nil,REASON_COST)
		local opt=0
		for i=1,ct do
			local b1=opt&1==0 and Duel.IsExists(false,s.setfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			local b2=opt&2==0 and Duel.IsExists(false,s.setfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
			local b4=opt&4==0 and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.setfilter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
			local k=aux.Option(tp,id,3,b1,b2,b4)
			opt=opt|(1<<k)
		end
		e:SetLabel(opt)
		if opt&1==1 then
			e:SetCategory(CATEGORY_POSITION)
			Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_MZONE)
		end
		if opt&2==2 then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,PLAYER_ALL,0)
		end
		if opt&4==4 then
			e:SetCategory(e:GetCategory()|CATEGORY_SPECIAL_SUMMON)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	local brk=false
	if opt&1==1 then
		local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.setfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThis(c))
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if tc:IsLocation(LOCATION_MZONE) then
				if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
					brk=true
				end
			else
				if Duel.ChangePosition(tc,POS_FACEDOWN)>0 then
					brk=true
					tc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
					tc:SetStatus(STATUS_SET_TURN,true)
					Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
					Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
				end
			end
			if brk then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_BANISH_REDIRECT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
				tc:RegisterEffect(e1,true)
			end
		end
	end
	if opt&2==2 then
		local g=Duel.Select(HINTMSG_SET,true,tp,aux.Necro(s.setfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
		if #g>0 then
			if brk then
				Duel.BreakEffect()
				brk=false
			end
			local tc=g:GetFirst()
			if Duel.SSet(tp,tc)>0 and tc:IsFacedown() and aux.PLChk(tc,tp,LOCATION_SZONE) then
				brk=true
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_BANISH_REDIRECT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
				tc:RegisterEffect(e1,true)
			end
		end
	end
	if opt&4==4 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,aux.Necro(s.setfilter3),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		if #g>0 then
			if brk then
				Duel.BreakEffect()
				brk=false
			end
			if Duel.SpecialSummonRedirect(e,g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end

--Filters E2
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToRemove()
end
--Text sections E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Banish(tc)>0 and tc:IsBanished() then
		local fid=e:GetFieldID()
		tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE,1,fid,aux.Stringid(id,4))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(5)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.setcon)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:HasFlagEffectLabel(id+100,e:GetLabel()) then
		e:Reset()
		return false
	else
		return true
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:HasFlagEffectLabel(id+100,e:GetLabel()) and tc:IsCanBeSet(e,tp) then
		Duel.Set(tp,tc)
	end
end

function s.acthandcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,nil)
end