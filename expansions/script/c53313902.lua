--Mysterious Blazar Dragon
function c53313902.initial_effect(c)
	--You can Special Summon this card (from your hand or GY) by Tributing 1 LIGHT monster you control and 1 "Mysterious" monster or card in your Pandemonium Zone. You can only Summon "Mysterious Blazar Dragon(s)" once per turn this way.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,53313902+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c53313902.sprcon)
	e1:SetTarget(c53313902.sprtg)
	e1:SetOperation(c53313902.sprop)
	c:RegisterEffect(e1)
	--If this card is Summoned: You can target 1 other Level/Rank 8 or lower face-up monster on the field; until the end of this turn, this card gains that target's effects (if any).
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetTarget(c53313902.target)
	e1:SetOperation(c53313902.operation)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--Once per turn, this card can't be destroyed by battle.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c53313902.valcon)
	c:RegisterEffect(e2)
end
function c53313902.rfilter(c)
	return c:IsMonster() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsSetCard(0xcf6))
end
function c53313902.pzfilter(c,alternative)
	return c:IsSetCard(0xcf6) and c:IsReleasable() and (aux.PaCheckFilter(c) or (alternative and c:IsLocation(LOCATION_MZONE)))
end
function c53313902.rfilter_check(c,sg)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and (not sg or sg:IsExists(c53313902.pzfilter,1,c,true))
end
function c53313902.gcheck(sg,tp)
	local cg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	return Duel.GetMZoneCount(tp,sg)>0 and Duel.CheckReleaseGroup(tp,Auxiliary.IsInGroup,#cg,nil,cg) and sg:IsExists(c53313902.rfilter_check,1,nil,sg)
end
function c53313902.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(c53313902.rfilter,nil)
	local rg2=Duel.Group(c53313902.pzfilter,tp,LOCATION_SZONE,0,nil)
	rg:Merge(rg2)
	local check=rg:CheckSubGroup(c53313902.gcheck,2,2,tp)
	return check
end
function c53313902.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(c53313902.rfilter,nil)
	local rg2=Duel.Group(c53313902.pzfilter,tp,LOCATION_SZONE,0,nil)
	rg:Merge(rg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,c53313902.gcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c53313902.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end


function c53313902.copytg(c)
	return c:IsFaceup() and c:IsMonster() and (c:IsLevelBelow(8) or c:IsRankBelow(8))
end
function c53313902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and c53313902.copytg(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c53313902.copytg,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313902.copytg,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
function c53313902.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(1162)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetLabel(cid)
		e3:SetLabelObject(e2)
		e3:SetOperation(c53313902.rstop)
		c:RegisterEffect(e3)
	end
end
function c53313902.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c53313902.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
