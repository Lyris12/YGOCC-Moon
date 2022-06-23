--Marmotor Bobak
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--ssproc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	--place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.pccon)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.gycon)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
--SSPROC
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local dis=Duel.SelectDisableField(tp,2,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE)
	e:SetLabel(dis)
	Duel.Hint(HINT_ZONE,tp,dis)
	if tp==1 then
		dis=((dis&0xffff)<<16)|((dis>>16)&0xffff)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(dis)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spval(e,c)
	return 0,~e:GetLabel()&0x1f
end

--PLACE
function s.pccon(e)
	return Duel.IsMainPhase()
end
function s.pcfilter(c,cc)
	local ct=(c:GetOwner()==cc:GetOwner()) and 1 or 0
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>ct
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.pcfilter(chkc,e:GetHandler()) end
	if chk==0 then return Duel.GetLocationCount(e:GetHandler():GetOwner(),LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.pcfilter,tp,0,LOCATION_MZONE,1,e:GetHandler(),e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.pcfilter,tp,0,LOCATION_MZONE,1,1,e:GetHandler(),e:GetHandler())
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c or not tc:IsFaceup() or not c:IsRelateToChain(0) or Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)<0 then return end
	if tc and tc:IsRelateToChain(0) and s.pcfilter(tc,c) then
		local fid=c:GetFieldID()
		local g=Group.FromCards(c,tc)
		local gc=g:GetFirst()
		while gc do
			if not gc:IsImmuneToEffect(e) and Duel.MoveToField(gc,tp,gc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
				gc:RegisterEffect(e1)
				if gc:IsPreviousLocation(LOCATION_MZONE) then
					if gc~=c and gc:IsLocation(LOCATION_SZONE) then
						gc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE,1,fid)
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						e2:SetCode(EVENT_PHASE+PHASE_END)
						e2:SetReset(RESET_PHASE+PHASE_END)
						e2:SetCountLimit(1)
						e2:SetLabel(fid)
						e2:SetLabelObject(gc)
						e2:SetOperation(s.retop)
						Duel.RegisterEffect(e2,tp)
					end
					if gc:GetPreviousSequence()<5 then
						local zone=(gc:GetPreviousControler()==tp) and 0x1<<gc:GetPreviousSequence() or 0x1<<(gc:GetPreviousSequence()+16)
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_FIELD)
						e1:SetCode(EFFECT_DISABLE_FIELD)
						e1:SetLabel(zone)
						e1:SetOperation(s.disop)
						e1:SetReset(RESET_PHASE+PHASE_END)
						Duel.RegisterEffect(e1,tp)
					end
				end
			end
			gc=g:GetNext()
		end
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetLabelObject()
	if not gc:IsLocation(LOCATION_SZONE) or gc:GetFlagEffectLabel(id)~=e:GetLabel() then return end
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 or not Duel.MoveToField(gc,tp,1-tp,LOCATION_MZONE,POS_FACEUP,true) then
		Duel.SendtoGrave(gc,REASON_EFFECT)
	end
end

--DESTROY
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()&0x20004==0x20004
end
function s.gyfilter(c)
	return c:IsFaceup() and c:GetType()&0x20004==0x20004 and c:GetColumnGroup():IsExists(aux.TRUE,1,c)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local gc=g:GetFirst():GetColumnGroup():Filter(aux.TRUE,g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,gc,#gc,0,0)
end
function s.mcheck(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and (c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER or c:IsPreviousPosition(POS_FACEDOWN))
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain(0) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain(0) then return end
	local g=tc:GetColumnGroup():Filter(aux.TRUE,tc)
	if #g==0 then return end
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(s.mcheck,nil)
		if #og==0 then return end
		local oc=og:GetFirst()
		for oc in aux.Next(og) do
			local zone=(oc:GetPreviousControler()==tp) and 0x1<<oc:GetPreviousSequence() or 0x1<<(oc:GetPreviousSequence()+16)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetLabel(zone)
			e1:SetOperation(s.disop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end