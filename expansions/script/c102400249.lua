--created & coded by Lyris, art at https://images-na.ssl-images-amazon.com/images/I/615xevWUOuL._UY741_.jpg
--ニュートリックス・ナイトヴェール
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LINK_SPELL_KOISHI)
	e3:SetValue(function() return e1:GetLabel() end)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(function(e,c) return c:IsSetCard(0xd10) and e:GetHandler():GetLinkedGroup():IsContains(c) end)
	e4:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetOwnerPlayer() end)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(s.checkop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetOperation(s.negop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd10) and c:GetSequence()<5
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:GetColumnGroup(1,1):Filter(s.filter,nil)==0 then Duel.Destroy(c,REASON_EFFECT) end
	local pt,t=0,{[-1]=LINK_MARKER_TOP_LEFT,[0]=LINK_MARKER_TOP,[1]=LINK_MARKER_TOP_RIGHT,}
	for i=-1,1 do if c:GetColumnGroup(i,-i):FilterCount(s.filter,nil)>0 then pt=pt|t[i] end end
	if pt==0 then Duel.Destroy(c,REASON_EFFECT)
	else e:SetLabel(pt) end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then e:SetLabel(0)
	else
		e:SetLabel(e:GetHandler():GetLinkedGroupCount())
		local g=e:GetHandler():GetLinkedGroup()
		g:KeepAlive()
		e:SetLabelObject(g)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()==0 then return end
	local g=e:GetLabelObject():GetLabelObject()
	for tc in aux.Next(e:GetLabelObject():GetLabelObject()) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetOperation(function() e1:SetReset(RESET_EVENT+RESETS_STANDARD) e2:SetReset(RESET_EVENT+RESETS_STANDARD) e3:Reset() end)
		e3:SetReset(RESET_EVENT+RESET_TURN_SET+RESET_TOFIELD)
		tc:RegisterEffect(e3)
	end
	g:DeleteGroup()
end
