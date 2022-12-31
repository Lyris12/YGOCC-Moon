--Lethal Meatal Grinder
--Script by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
--DESTROY
function cid.filter(c,e)
	if c:IsType(TYPE_TOKEN) then return false end
	return ((c:IsLocation(LOCATION_MZONE) and (c:IsFacedown() or c:IsType(TYPE_MONSTER))) or c:IsType(TYPE_MONSTER)) and (not e or c:IsDestructable(e))
end
function cid.excfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function cid.excfilter2(c)
	return c:IsType(TYPE_MONSTER) or c:IsFacedown()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,tp,0)
	local sg=Duel.GetMatchingGroup(cid.excfilter,tp,0,LOCATION_ONFIELD,nil)
	if #sg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	end
	local sg2=Duel.GetMatchingGroup(cid.excfilter2,tp,0,LOCATION_MZONE,nil)
	if #sg2>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg2,1,0,0)
	end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_EXTRA)
	end
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE) then
		Duel.SetChainLimit(cid.chlimit)
	end
end
function cid.chlimit(e,ep,tp)
	return tp==ep
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,0,1,99,nil,nil)
	if #g>0 then
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct==0 then return end
		local og=Duel.GetOperatedGroup()
		local b1=(ct>=1 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil))
		local b2=(ct>=2 and e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup())
		local b3=(ct>=3 and Duel.IsExistingMatchingCard(cid.excfilter,tp,0,LOCATION_ONFIELD,1,nil))
		local b4=(ct>=4 and Duel.IsExistingMatchingCard(cid.excfilter2,tp,0,LOCATION_MZONE,1,nil))
		local b5=(ct>=5 and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>=ct)
		local b={b1,b2,b3,b4,b5}
		if not b[1] and not b[2] and not b[3] and not b[4] and not b[5] then return end
		local off=1
		local ops={}
		local opval={}
		for i=1,5 do
			if b[i] then
				ops[off]=aux.Stringid(id,i)
				opval[off]=i-1
				off=off+1
			end
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel={}
		table.insert(sel,opval[op])
		if #ops>1 and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			table.remove(ops,op)
			local op=Duel.SelectOption(tp,table.unpack(ops))+1
			table.insert(sel,opval[op])
		end
		for i=1,#sel do
			if sel[i]==0 then
				local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
				if #sg<=0 then return end
				for tc in aux.Next(sg) do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(og:GetSum(Card.GLGetOriginalLevel)*-200)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e1x=e1:Clone()
					e1x:SetCode(EFFECT_UPDATE_DEFENSE)
					tc:RegisterEffect(e1x)
				end
			elseif sel[i]==1 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(og:GetSum(Card.GetTextAttack))
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)
				local e1x=e1:Clone()
				e1x:SetCode(EFFECT_UPDATE_DEFENSE)
				e1x:SetValue(og:GetSum(Card.GetTextDefense))
				c:RegisterEffect(e1x)
			elseif sel[i]==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectMatchingCard(tp,cid.excfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
				if #g>0 then
					Duel.HintSelection(g)
					Duel.Destroy(g,REASON_EFFECT)
				end
			elseif sel[i]==3 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local g=Duel.SelectMatchingCard(tp,cid.excfilter2,tp,0,LOCATION_MZONE,1,ct,nil)
				if #g>0 then
					Duel.HintSelection(g)
					Duel.Destroy(g,REASON_EFFECT)
				end
			else
				local rg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
				Duel.ConfirmCards(tp,rg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=rg:Select(tp,ct,ct,nil)
				if #tg>0 then
					Duel.Destroy(tg,REASON_EFFECT)
					Duel.ShuffleExtra(1-tp)
				end
			end
		end
	end
end
		
		
		